<?php

namespace App\Services;

use App\Models\Report;
use App\Models\SalesInvoice;
use App\Models\Batch;
use Carbon\Carbon;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Facades\Storage;

class ReportService
{
    public function generateDailyReport($date = null)
    {
        $date = $date ?? Carbon::today();
        
        // 1. Gather Data
        $sales = SalesInvoice::whereDate('created_at', $date)->get();
        $totalSales = $sales->sum('total');
        $totalTransactions = $sales->count();
        
        // Inventory warnings
        $lowStock = Batch::where('quantity', '<', 10)->with('medicine')->take(20)->get();
        $expiring = Batch::where('expiry_date', '<', Carbon::now()->addDays(30))->with('medicine')->take(20)->get();

        $data = [
            'date' => $date->format('Y-m-d'),
            'total_sales' => $totalSales,
            'total_transactions' => $totalTransactions,
            'low_stock' => $lowStock,
            'expiring' => $expiring,
            'sales_list' => $sales
        ];

        // 2. Generate PDF
        $pdf = Pdf::loadView('reports.daily_pdf', $data);
        $fileName = 'daily_report_' . $date->format('Y_m_d') . '.pdf';
        $filePath = 'reports/' . $fileName;

        // 3. Save File
        Storage::disk('public')->put($filePath, $pdf->output());

        // 4. Save Record
        $report = Report::create([
            'report_date' => $date,
            'file_path' => $filePath,
            'type' => 'daily',
            'total_sales' => $totalSales,
        ]);

        return $report;
    }
}
