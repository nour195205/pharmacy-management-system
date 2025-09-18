<?php

namespace App\Http\Controllers;

use App\Models\SalesInvoice;
use App\Models\SalesInvoiceItem;
use App\Models\Batch;
use App\Models\Branch;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SalesInvoiceController extends Controller
{
    public function index()
    {
        $invoices = SalesInvoice::with('branch', 'creator')->latest()->paginate(10);
        return view('sales_invoices.index', compact('invoices'));
    }

    public function create()
    {
        $availableBatches = Batch::where('quantity', '>', 0)->with('medicine', 'branch')->get();
        $branches = Branch::all();
        return view('sales_invoices.create', compact('availableBatches', 'branches'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'branch_id' => 'required|exists:branches,id',
            'date' => 'required|date',
            'status' => 'required|in:مدفوع,معلق,ملغى',
            'payment_method' => 'required|in:نقدا,بطاقة,أخرى',
            'note' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.batch_id' => 'required|exists:batches,id',
            'items.*.quantity' => 'required|numeric|min:0.01',
        ]);

        DB::beginTransaction();
        try {
            $totalAmount = 0;
            $currentUser = auth()->id();

            $salesInvoice = SalesInvoice::create([
                'branch_id' => $request->branch_id,
                'date' => $request->date,
                'status' => $request->status,
                'payment_method' => $request->payment_method,
                'note' => $request->note,
                'created_by' => $currentUser,
                'total' => 0, // سيتم تحديثه
            ]);

            foreach ($request->items as $itemData) {
                if (empty($itemData['quantity']) || $itemData['quantity'] <= 0)
                    continue;

                $batch = Batch::findOrFail($itemData['batch_id']);

                if ($itemData['quantity'] > $batch->quantity) {
                    throw new \Exception("الكمية المطلوبة للدواء {$batch->medicine->name} تتجاوز الكمية المتاحة.");
                }

                $sellingPrice = $batch->selling_price;
                $total = $itemData['quantity'] * $sellingPrice;
                $totalAmount += $total;

                SalesInvoiceItem::create([
                    'sales_invoice_id' => $salesInvoice->id,
                    'batch_id' => $batch->id,
                    'qty' => $itemData['quantity'],
                    'price' => $sellingPrice,
                    'total' => $total,
                ]);

                $batch->decrement('quantity', $itemData['quantity']);
            }

            if ($totalAmount <= 0)
                throw new \Exception("يجب بيع كمية واحدة على الأقل.");

            $salesInvoice->update(['total' => $totalAmount]);

            DB::commit();

            return redirect()->route('sales-invoices.index')->with('success', 'تم تسجيل فاتورة المبيعات بنجاح.');

        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->with('error', 'حدث خطأ: ' . $e->getMessage())->withInput();
        }
    }
    /**
     * Display the specified resource.
     */
    public function show(SalesInvoice $salesInvoice)
    {
        // تحميل كل البيانات اللازمة لعرض الفاتورة بشكل كامل
        $salesInvoice->load('items.batch.medicine', 'branch', 'creator');
        return view('sales_invoices.show', compact('salesInvoice'));
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(SalesInvoice $salesInvoice)
    {
        DB::beginTransaction();
        try {
            // الخطوة 1: إرجاع الكميات المباعة إلى المخزون (أهم خطوة)
            foreach ($salesInvoice->items as $item) {
                $batch = Batch::find($item->batch_id);
                if ($batch) {
                    // زيادة الكمية في التشغيلة بالكمية التي تم بيعها
                    $batch->increment('quantity', $item->qty);
                }
            }

            // الخطوة 2: حذف الفاتورة وبنودها
            $salesInvoice->delete();

            DB::commit();

            return redirect()->route('sales-invoices.index')->with('success', 'تم حذف فاتورة المبيعات وإرجاع الكميات للمخزون بنجاح.');

        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->with('error', 'حدث خطأ أثناء حذف الفاتورة: ' . $e->getMessage());
        }
    }

    public function receipt(SalesInvoice $salesInvoice)
    {
        $salesInvoice->load('items.batch.medicine', 'branch', 'creator');
        return view('sales_invoices.receipt', compact('salesInvoice'));
    }
    /**
     * Show the form for editing the specified resource.
     */
    public function edit(SalesInvoice $salesInvoice)
    {
        // تحميل البيانات اللازمة للعرض
        $salesInvoice->load('items.batch.medicine');
        $branches = Branch::all();
        // جلب كل الدفعات المتاحة حاليًا بالإضافة للدفعات القديمة للفاتورة (حتى لو نفدت كميتها)
        $currentBatchesIds = $salesInvoice->items->pluck('batch_id');
        $availableBatches = Batch::where('quantity', '>', 0)
                                ->orWhereIn('id', $currentBatchesIds)
                                ->with('medicine', 'branch')
                                ->get();

        return view('sales_invoices.edit', compact('salesInvoice', 'branches', 'availableBatches'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, SalesInvoice $salesInvoice)
    {
        $request->validate([
            'branch_id' => 'required|exists:branches,id',
            'date' => 'required|date',
            'status' => 'required|in:مدفوع,معلق,ملغى',
            'payment_method' => 'required|in:نقدا,بطاقة,أخرى',
            'note' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.batch_id' => 'required|exists:batches,id',
            'items.*.quantity' => 'required|numeric|min:0.01',
        ]);

        DB::beginTransaction();
        try {
            // الخطوة 1: إرجاع كل الكميات القديمة إلى المخزون
            foreach ($salesInvoice->items as $oldItem) {
                Batch::find($oldItem->batch_id)->increment('quantity', $oldItem->qty);
            }
            // حذف بنود الفاتورة القديمة
            $salesInvoice->items()->delete();

            $totalAmount = 0;
            $currentUser = auth()->id();

            // الخطوة 2: إضافة البنود الجديدة وخصمها من المخزون
            foreach ($request->items as $itemData) {
                if (empty($itemData['quantity']) || $itemData['quantity'] <= 0) continue;

                $batch = Batch::findOrFail($itemData['batch_id']);

                // التحقق من أن الكمية الجديدة لا تتجاوز الكمية المتاحة الآن
                if ($itemData['quantity'] > $batch->quantity) {
                    throw new \Exception("الكمية المطلوبة للدواء {$batch->medicine->name} تتجاوز الكمية المتاحة.");
                }

                $sellingPrice = $batch->selling_price;
                $total = $itemData['quantity'] * $sellingPrice;
                $totalAmount += $total;

                SalesInvoiceItem::create([
                    'sales_invoice_id' => $salesInvoice->id,
                    'batch_id' => $batch->id,
                    'qty' => $itemData['quantity'],
                    'price' => $sellingPrice,
                    'total' => $total,
                ]);

                // خصم الكمية الجديدة من المخزون
                $batch->decrement('quantity', $itemData['quantity']);
            }

            if ($totalAmount <= 0) throw new \Exception("يجب بيع كمية واحدة على الأقل.");

            // الخطوة 3: تحديث بيانات الفاتورة الأساسية
            $salesInvoice->update([
                'branch_id' => $request->branch_id,
                'date' => $request->date,
                'status' => $request->status,
                'payment_method' => $request->payment_method,
                'note' => $request->note,
                'created_by' => $currentUser,
                'total' => $totalAmount,
            ]);

            DB::commit();

            return redirect()->route('sales-invoices.index')->with('success', 'تم تعديل فاتورة المبيعات بنجاح.');

        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->with('error', 'حدث خطأ: ' . $e->getMessage())->withInput();
        }
    }
}