<?php

namespace App\Http\Controllers;

use App\Models\Medicine;
use App\Models\Supplier;
use App\Models\PurchaseInvoice;
use App\Models\SalesInvoice;
use App\Models\PurchaseReturn;
use App\Models\SalesReturn;
use App\Models\Batch;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index()
    {
        // --- الإحصائيات العامة ---
        $totalMedicines = Medicine::count();
        $totalSuppliers = Supplier::count();
        
        // --- إحصائيات المبيعات والمشتريات (الصافي) ---
        $today = Carbon::today();

        // حساب صافي المبيعات
        $grossSalesToday = SalesInvoice::whereDate('date', $today)->sum('total');
        $salesReturnsToday = SalesReturn::whereDate('date', $today)->sum('total');
        $netSalesToday = $grossSalesToday - $salesReturnsToday;

        // حساب صافي المشتريات
        $grossPurchasesToday = PurchaseInvoice::whereDate('invoice_date', $today)->sum('total_amount');
        $purchaseReturnsToday = PurchaseReturn::whereDate('date', $today)->sum('total');
        $netPurchasesToday = $grossPurchasesToday - $purchaseReturnsToday;

        // --- الأدوية التي على وشك النفاذ ---
        // ====== ابدأ التعديل هنا ======
        $lowStockMedicines = Batch::select('medicine_id', DB::raw('SUM(quantity) as total_quantity'))
            ->groupBy('medicine_id')
            // نستخدم having مرتين بدلاً من where للتحقق من القيم المجمعة
            ->having('total_quantity', '<=', 10)
            ->having('total_quantity', '>', 0)
            ->with('medicine')
            ->get();
        // ====== انتهي من التعديل هنا ======
            
        // --- الأدوية التي على وشك الانتهاء ---
        $expiringSoonBatches = Batch::where('expiry_date', '>=', $today)
            ->where('expiry_date', '<=', $today->copy()->addDays(90))
            ->where('quantity', '>', 0)
            ->with('medicine', 'branch')
            ->orderBy('expiry_date', 'asc')
            ->get();

        return view('dashboard', compact(
            'totalMedicines',
            'totalSuppliers',
            'netSalesToday',
            'netPurchasesToday',
            'lowStockMedicines',
            'expiringSoonBatches'
        ));
    }
}