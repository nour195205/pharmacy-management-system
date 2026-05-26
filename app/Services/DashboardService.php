<?php

namespace App\Services;

use App\Models\Batch;
use App\Models\Medicine;
use App\Models\PurchaseInvoice;
use App\Models\PurchaseReturn;
use App\Models\SalesInvoice;
use App\Models\SalesReturn;
use App\Models\Supplier;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class DashboardService
{
    public function getDashboardData(): array
    {
        $totalMedicines = Medicine::count();
        $totalSuppliers = Supplier::count();

        $today = Carbon::today();

        $grossSalesToday = SalesInvoice::whereDate('date', $today)->sum('total');
        $salesReturnsToday = SalesReturn::whereDate('date', $today)->sum('total');
        $netSalesToday = $grossSalesToday - $salesReturnsToday;

        $grossPurchasesToday = PurchaseInvoice::whereDate('invoice_date', $today)->sum('total_amount');
        $purchaseReturnsToday = PurchaseReturn::whereDate('date', $today)->sum('total');
        $netPurchasesToday = $grossPurchasesToday - $purchaseReturnsToday;

        $lowStockMedicines = Batch::join('medicines', 'batches.medicine_id', '=', 'medicines.id')
            ->select(
                'medicines.name as medicine_name',
                DB::raw('SUM(batches.quantity) as total_quantity')
            )
            ->groupBy('medicines.id', 'medicines.name', 'medicines.reorder_level')
            ->havingRaw('SUM(batches.quantity) <= medicines.reorder_level AND SUM(batches.quantity) > 0')
            ->get();

        $expiringSoonBatches = Batch::where('expiry_date', '>=', $today)
            ->where('expiry_date', '<=', $today->copy()->addDays(90))
            ->where('quantity', '>', 0)
            ->with('medicine', 'branch')
            ->orderBy('expiry_date', 'asc')
            ->get();

        return compact(
            'totalMedicines',
            'totalSuppliers',
            'netSalesToday',
            'netPurchasesToday',
            'lowStockMedicines',
            'expiringSoonBatches'
        );
    }
}
