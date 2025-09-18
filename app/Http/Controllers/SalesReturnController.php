<?php

namespace App\Http\Controllers;

use App\Models\SalesInvoice;
use App\Models\SalesReturn;
use App\Models\SalesReturnItem;
use App\Models\Batch;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SalesReturnController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $returns = SalesReturn::with('salesInvoice.branch', 'creator')->latest()->paginate(10);
        return view('sales_returns.index', compact('returns'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create(Request $request)
    {
        $invoice_id = $request->query('invoice_id');
        if (!$invoice_id) {
            $invoices = SalesInvoice::latest()->get();
            return view('sales_returns.select_invoice', compact('invoices'));
        }

        $invoice = SalesInvoice::with('items.batch.medicine')->findOrFail($invoice_id);

        return view('sales_returns.create', compact('invoice'));
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'sales_invoice_id' => 'required|exists:sales_invoices,id',
            'date' => 'required|date',
            'reason' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.sales_item_id' => 'required|exists:sales_invoice_items,id',
            'items.*.quantity' => 'required|numeric|min:0.01',
        ]);

        DB::beginTransaction();
        try {
            $invoice = SalesInvoice::findOrFail($request->sales_invoice_id);
            $totalReturnAmount = 0;
            $returnedItemsCount = 0;
            $currentUser = auth()->id();

            $salesReturn = SalesReturn::create([
                'sales_invoice_id' => $invoice->id,
                'date' => $request->date,
                'reason' => $request->reason,
                'created_by' => $currentUser,
                'total' => 0, // سيتم تحديثه
            ]);

            foreach ($request->items as $itemData) {
                if (empty($itemData['quantity']) || $itemData['quantity'] <= 0) continue;

                $returnedItemsCount++;
                $salesItem = \App\Models\SalesInvoiceItem::findOrFail($itemData['sales_item_id']);
                $batch = $salesItem->batch;

                // التحقق من أن الكمية المرتجعة لا تتجاوز الكمية التي تم بيعها أصلاً
                if ($itemData['quantity'] > $salesItem->qty) {
                    throw new \Exception("الكمية المرتجعة للدواء {$batch->medicine->name} ({$itemData['quantity']}) تتجاوز الكمية المباعة ({$salesItem->qty}).");
                }

                $sellingPrice = $salesItem->price;
                $total = $itemData['quantity'] * $sellingPrice;
                $totalReturnAmount += $total;

                SalesReturnItem::create([
                    'sales_return_id' => $salesReturn->id,
                    'batch_id' => $batch->id,
                    'quantity' => $itemData['quantity'],
                    'selling_price' => $sellingPrice,
                    'total' => $total,
                ]);

                // أهم خطوة: إرجاع الكمية إلى المخزون (التشغيلة)
                $batch->increment('quantity', $itemData['quantity']);
            }
            
            if ($returnedItemsCount === 0) {
                throw new \Exception("يجب إرجاع كمية واحدة على الأقل.");
            }

            $salesReturn->update(['total' => $totalReturnAmount]);

            DB::commit();

            return redirect()->route('sales-returns.index')->with('success', 'تم تسجيل مرتجع المبيعات بنجاح.');

        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->with('error', 'حدث خطأ: ' . $e->getMessage())->withInput();
        }
    }
}