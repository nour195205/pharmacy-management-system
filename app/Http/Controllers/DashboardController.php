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
        $totalMedicines = Medicine::count();
        $totalSuppliers = Supplier::count();
        
        $today = Carbon::today();

        $grossSalesToday = SalesInvoice::whereDate('date', $today)->sum('total');
        $salesReturnsToday = SalesReturn::whereDate('date', $today)->sum('total');
        $netSalesToday = $grossSalesToday - $salesReturnsToday;

        $grossPurchasesToday = PurchaseInvoice::whereDate('invoice_date', $today)->sum('total_amount');
        $purchaseReturnsToday = PurchaseReturn::whereDate('date', $today)->sum('total');
        $netPurchasesToday = $grossPurchasesToday - $purchaseReturnsToday;

        // ====== ابدأ التعديل هنا ======
        // --- الأدوية التي على وشك النفاذ (بناءً على حد إعادة الطلب) ---
        $lowStockMedicines = Batch::join('medicines', 'batches.medicine_id', '=', 'medicines.id')
            ->select(
                'medicines.name as medicine_name', // اختيار اسم الدواء مباشرة
                DB::raw('SUM(batches.quantity) as total_quantity')
            )
            ->groupBy('medicines.id', 'medicines.name', 'medicines.reorder_level')
            ->havingRaw('SUM(batches.quantity) <= medicines.reorder_level AND SUM(batches.quantity) > 0')
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