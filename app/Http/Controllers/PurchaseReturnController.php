<?php

namespace App\Http\Controllers;

use App\Models\PurchaseInvoice;
use App\Models\PurchaseReturn;
use App\Models\PurchaseReturnItem;
use App\Models\Batch;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class PurchaseReturnController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $returns = PurchaseReturn::with('purchaseInvoice.supplier')->latest()->paginate(10);
        return view('purchase_returns.index', compact('returns'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create(Request $request)
    {
        $invoice_id = $request->query('invoice_id');
        if (!$invoice_id) {
            // إذا لم يتم تحديد فاتورة، اعرض قائمة بالفواتير للاختيار منها
            $invoices = PurchaseInvoice::with('supplier')->latest()->get();
            return view('purchase_returns.select_invoice', compact('invoices'));
        }

        $invoice = PurchaseInvoice::with('items.batch.medicine')->findOrFail($invoice_id);

        // حساب الكميات المرتجعة سابقاً لكل دفعة
        $returnedQuantities = PurchaseReturnItem::whereIn('batch_id', $invoice->items->pluck('batch_id'))
            ->groupBy('batch_id')
            ->select('batch_id', DB::raw('SUM(quantity) as total_returned'))
            ->pluck('total_returned', 'batch_id');

        return view('purchase_returns.create', compact('invoice', 'returnedQuantities'));
    }

    /**
     * Store a newly created resource in storage.
     */
    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        // استخدام الأسماء الصحيحة من الداتا بيز بتاعتك
        $request->validate([
            'purchase_invoice_id' => 'required|exists:purchase_invoices,id',
            'date' => 'required|date',
            'reason' => 'nullable|string', // <-- اسم صحيح
            'items' => 'required|array',
            'items.*.batch_id' => 'required|exists:batches,id',
            'items.*.quantity' => 'nullable|integer|min:0',
        ]);

        DB::beginTransaction();
        try {
            $invoice = PurchaseInvoice::findOrFail($request->purchase_invoice_id);
            $totalReturnAmount = 0;
            $returnedItemsCount = 0;
            $currentUser = auth()->id(); // المستخدم الحالي

            $purchaseReturn = PurchaseReturn::create([
                'purchase_invoice_id' => $invoice->id,
                'user_id' => $currentUser,
                'date' => $request->date,
                'reason' => $request->reason, // <-- اسم صحيح
                'total' => 0, // <-- اسم صحيح (سيتم تحديثه)
                'created_by' => $currentUser, // <-- اسم صحيح
            ]);

            foreach ($request->items as $itemData) {
                if (empty($itemData['quantity']) || $itemData['quantity'] <= 0) {
                    continue;
                }
                
                $returnedItemsCount++;
                $batch = Batch::findOrFail($itemData['batch_id']);

                if ($itemData['quantity'] > $batch->quantity) {
                    throw new \Exception("الكمية المرتجعة للدواء {$batch->medicine->name} تتجاوز الكمية المتاحة.");
                }

                $purchasePrice = $batch->purchase_price;
                $total = $itemData['quantity'] * $purchasePrice;
                $totalReturnAmount += $total;

                PurchaseReturnItem::create([
                    'purchase_return_id' => $purchaseReturn->id,
                    'batch_id' => $batch->id,
                    'quantity' => $itemData['quantity'],
                    'purchase_price' => $purchasePrice,
                    'total' => $total,
                ]);

                $batch->decrement('quantity', $itemData['quantity']);
            }
            
            if ($returnedItemsCount === 0) {
                throw new \Exception("يجب إرجاع كمية واحدة على الأقل.");
            }

            // تحديث الإجمالي في فاتورة المرتجع
            $purchaseReturn->update(['total' => $totalReturnAmount]);

            DB::commit();

            return redirect()->route('purchase-returns.index')->with('success', 'تم تسجيل فاتورة المرتجع بنجاح!');

        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->with('error', 'حدث خطأ: ' . $e->getMessage())->withInput();
        }
    }
}