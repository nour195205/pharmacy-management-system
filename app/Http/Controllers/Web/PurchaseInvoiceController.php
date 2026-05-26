<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\StorePurchaseInvoiceRequest;
use App\Http\Requests\UpdatePurchaseInvoiceRequest;
use App\Models\PurchaseInvoice;
use App\Services\PurchaseInvoiceService;

class PurchaseInvoiceController extends Controller
{
    public function __construct(private PurchaseInvoiceService $purchaseInvoiceService) {}

    public function index()
    {
        $invoices = $this->purchaseInvoiceService->getPaginated();
        return view('purchase_invoices.index', compact('invoices'));
    }

    public function create()
    {
        $formData = $this->purchaseInvoiceService->getFormData();
        return view('purchase_invoices.create', $formData);
    }

    public function store(StorePurchaseInvoiceRequest $request)
    {
        try {
            $this->purchaseInvoiceService->store($request->validated(), auth()->id());
            return redirect()->route('purchase-invoices.index')
                ->with('success', 'فاتورة المشتريات تم إضافتها بنجاح.');
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'حدث خطأ أثناء حفظ الفاتورة: ' . $e->getMessage())
                ->withInput();
        }
    }

    public function show(PurchaseInvoice $purchaseInvoice)
    {
        $purchaseInvoice->load('items.batch.medicine', 'branch', 'supplier', 'user');
        return view('purchase_invoices.show', compact('purchaseInvoice'));
    }

    public function edit(PurchaseInvoice $purchaseInvoice)
    {
        $purchaseInvoice->load('items.batch.medicine', 'branch', 'supplier');
        $formData = $this->purchaseInvoiceService->getFormData();
        return view('purchase_invoices.edit', array_merge(['purchaseInvoice' => $purchaseInvoice], $formData));
    }

    public function update(UpdatePurchaseInvoiceRequest $request, PurchaseInvoice $purchaseInvoice)
    {
        try {
            $this->purchaseInvoiceService->update($purchaseInvoice, $request->validated());
            return redirect()->route('purchase-invoices.index')
                ->with('success', 'تم تعديل فاتورة المشتريات بنجاح!');
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'حدث خطأ أثناء تعديل الفاتورة: ' . $e->getMessage())
                ->withInput();
        }
    }

    public function destroy(PurchaseInvoice $purchaseInvoice)
    {
        try {
            $this->purchaseInvoiceService->delete($purchaseInvoice);
            return redirect()->route('purchase-invoices.index')
                ->with('success', 'فاتورة المشتريات تم حذفها بنجاح.');
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'حدث خطأ أثناء حذف الفاتورة: ' . $e->getMessage());
        }
    }

    public function print(PurchaseInvoice $purchaseInvoice)
    {
        $purchaseInvoice->load('items.batch.medicine', 'branch', 'supplier', 'user');
        return view('purchase_invoices.print', compact('purchaseInvoice'));
    }
}
