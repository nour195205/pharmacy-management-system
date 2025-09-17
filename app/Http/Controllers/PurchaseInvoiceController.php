<?php

namespace App\Http\Controllers;

use App\Models\Batch;
use App\Models\Medicine;
use App\Models\PurchaseInvoice;
use App\Models\PurchaseInvoiceItem;
use App\Models\Supplier;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class PurchaseInvoiceController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $invoices = PurchaseInvoice::with('supplier')->latest()->paginate(10);
        return view('purchase_invoices.index', compact('invoices'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        $suppliers = \App\Models\Supplier::all();
        $medicines = \App\Models\Medicine::all();
        $branches = \App\Models\Branch::all(); // <-- أضف هذا السطر
        return view('purchase_invoices.create', compact('suppliers', 'medicines', 'branches')); // <-- أضف branches هنا
    }
    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        // dd($request->all());
        // 1. Validate the main purchase invoice data.
        $request->validate([
            'branch_id' => 'required|exists:branches,id', // <-- أضف هذا السطر
            'supplier_id' => 'required|exists:suppliers,id',
            'invoice_date' => 'required|date',
            'items' => 'required|array|min:1',
            'items.*.medicine_id' => 'required|exists:medicines,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.purchase_price' => 'required|numeric|min:0',
            'items.*.selling_price' => 'required|numeric|min:0|gt:items.*.purchase_price', // <-- أضف هذا
            
            'items.*.manufacture_date' => 'required|date', // <-- أضف هذا
            'items.*.expiry_date' => 'required|date|after:items.*.manufacture_date', // <-- عدّل هذا
        ]);

        try {
            DB::beginTransaction();

            // 2. Create the main purchase invoice record.
            $invoice = \App\Models\PurchaseInvoice::create([
                'branch_id' => $request->branch_id, // <-- أضف هذا السطر
                'supplier_id' => $request->supplier_id,
                'user_id' => auth()->id(),
                'invoice_date' => $request->invoice_date,
                'total_amount' => 0,
                
            ]);

            $totalAmount = 0;

            // 3. Loop through items and add them to the invoice and update stock.
            // ... (الكود اللي قبل الحلقة)

            // 3. Loop through items and add them to the invoice and update stock.
            foreach ($request->items as $item) {
                // Get the medicine details.
                // $medicine = \App\Models\Medicine::find($item['medicine_id']);

                // // Create a new batch for the purchased medicine.
                // $batch = \App\Models\Batch::create([
                //     'branch_id' => $request->branch_id, // <-- هذا هو السطر الأخير
                //     'medicine_id' => $medicine->id,
                //     'batch_number' => 'BATCH-' . $medicine->id . '-' . time(),
                //     'manufacture_date' => $item['manufacture_date'], // <-- أضف هذا
                //     'expiry_date' => $item['expiry_date'],
                //     'quantity' => $item['quantity'],
                //     'purchase_price' => $item['purchase_price'], // <-- هذا هو السطر الأخير
                //     'selling_price' => $medicine->selling_price, // <-- هذا هو السطر الأخير
                    
                // ]);

                $medicine = \App\Models\Medicine::find($item['medicine_id']);

                $batch = \App\Models\Batch::create([
                    'branch_id' => $request->branch_id,
                    'medicine_id' => $medicine->id,
                    'qty' => $item['quantity'], // <-- هنا بنستخدم الاسم الصح qty
                    'price' => $item['purchase_price'], // <-- بنضيف السعر
                    // 'batch_number' => 'BATCH-' . $medicine->id . '-' . time(),
                    'batch_number' => 'BATCH-' . $medicine->id . '-' . time() . '-' . rand(100, 999),
                    'manufacture_date' => $item['manufacture_date'], // <-- التعديل النهائي هنا
                    // <-- سنضع تاريخ اليوم مؤقتاً
                    'expiry_date' => $item['expiry_date'],
                    'quantity' => $item['quantity'],
                    'purchase_price' => $item['purchase_price'],
                    'selling_price' => $item['selling_price'], // <-- التعديل النهائي هنا
                ]);
                // ... باقي الكود زي ما هو ...
            

            // ...

                // Create the purchase invoice item record.
                PurchaseInvoiceItem::create([
                    'purchase_invoice_id' => $invoice->id,
                    // 'medicine_id' => $medicine->id,
                    'batch_id' => $batch->id,
                    'quantity' => $item['quantity'],
                    'qty' => $item['quantity'],      // <-- هنا بنستخدم الاسم الصح qty
                    'price' => $item['purchase_price'],
                    'purchase_price' => $item['purchase_price'],
                    'sale_price' => $medicine->sale_price, // Assuming sale price from medicine model
                ]);

                // Update the total quantity of the medicine in the medicines table.
                // $medicine->increment('stock_quantity', $item['quantity']);

                // Add to the total amount of the invoice.
                $totalAmount += $item['quantity'] * $item['purchase_price'];
            }

            // 4. Update the total amount on the main invoice.
            $invoice->update(['total_amount' => $totalAmount]);

            DB::commit();

            return redirect()->route('purchase-invoices.index')->with('success', 'فاتورة المشتريات تم إضافتها بنجاح.');

        } catch (\Exception $e) {
            DB::rollBack();
            dd($e);
            // يمكنك الآن إرجاع الكود لحالته الأصلية
            // return redirect()->back()->with('error', 'حدث خطأ أثناء حفظ الفاتورة: ' . $e->getMessage())->withInput();
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(PurchaseInvoice $purchaseInvoice)
    {
        // Load invoice items with medicine details
        $purchaseInvoice->load('items.medicine', 'supplier');
        return view('purchase_invoices.show', compact('purchaseInvoice'));
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(PurchaseInvoice $purchaseInvoice)
    {
        // Not implemented for now due to complexity of stock reversal.
        return redirect()->route('purchase-invoices.index')->with('error', 'لا يمكن تعديل فاتورة مشتريات.');
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, PurchaseInvoice $purchaseInvoice)
    {
        // Not implemented for now.
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(PurchaseInvoice $purchaseInvoice)
    {
        try {
            DB::beginTransaction();

            // 1. Reverse the stock for each item in the invoice.
            foreach ($purchaseInvoice->items as $item) {
                $medicine = Medicine::find($item->medicine_id);
                if ($medicine) {
                    $medicine->decrement('stock_quantity', $item->quantity);
                }
            }

            // 2. Delete the invoice and its items.
            $purchaseInvoice->delete();

            DB::commit();

            return redirect()->route('purchase-invoices.index')->with('success', 'فاتورة المشتريات تم حذفها بنجاح.');

        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->with('error', 'حدث خطأ أثناء حذف الفاتورة: ' . $e->getMessage());
        }


    }

    public function print(PurchaseInvoice $purchaseInvoice)
    {
        // Load invoice items with medicine details for printing
        $purchaseInvoice->load('items.medicine', 'supplier', 'user');
        return view('purchase_invoices.print', compact('purchaseInvoice'));
    }
}