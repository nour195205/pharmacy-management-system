<?php

namespace App\Http\Controllers;

use App\Models\Medicine;
use App\Models\Supplier;
use App\Models\PurchaseInvoice;
use App\Models\SalesInvoice;
use App\Models\Batch;
use Carbon\Carbon;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        // --- الإحصائيات العامة ---
        $totalMedicines = Medicine::count();
        $totalSuppliers = Supplier::count();

        // --- إحصائيات المبيعات والمشتريات ---
        $today = Carbon::today();
        $salesToday = SalesInvoice::whereDate('date', $today)->sum('total');
        $purchasesToday = PurchaseInvoice::whereDate('invoice_date', $today)->sum('total_amount');

        // --- الأدوية التي على وشك النفاذ ---
        // سنعتبر أن الكمية المنخفضة هي 10 أو أقل
        $lowStockMedicines = Batch::select('medicine_id', \DB::raw('SUM(quantity) as total_quantity'))
            ->groupBy('medicine_id')
            ->having('total_quantity', '<=', 10)
            ->with('medicine')
            ->get();

        // --- الأدوية التي على وشك الانتهاء ---
        // سنعتبر الأدوية التي ستنتهي في الـ 90 يومًا القادمة
        $expiringSoonBatches = Batch::where('expiry_date', '>=', $today)
            ->where('expiry_date', '<=', $today->copy()->addDays(90))
            ->where('quantity', '>', 0)
            ->with('medicine', 'branch')
            ->orderBy('expiry_date', 'asc')
            ->get();

        return view('dashboard', compact(
            'totalMedicines',
            'totalSuppliers',
            'salesToday',
            'purchasesToday',
            'lowStockMedicines',
            'expiringSoonBatches'
        ));
    }
}