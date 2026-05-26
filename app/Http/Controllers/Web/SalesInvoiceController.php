<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreSalesInvoiceRequest;
use App\Http\Requests\UpdateSalesInvoiceRequest;
use App\Models\SalesInvoice;
use App\Services\SalesInvoiceService;

class SalesInvoiceController extends Controller
{
    public function __construct(private SalesInvoiceService $salesInvoiceService) {}

    public function index()
    {
        $invoices = $this->salesInvoiceService->getPaginated();
        return view('sales_invoices.index', compact('invoices'));
    }

    public function create()
    {
        $formData = $this->salesInvoiceService->getFormData();
        return view('sales_invoices.create', $formData);
    }

    public function store(StoreSalesInvoiceRequest $request)
    {
        try {
            $this->salesInvoiceService->store($request->validated(), auth()->id());
            return redirect()->route('sales-invoices.index')
                ->with('success', 'تم تسجيل فاتورة المبيعات بنجاح.');
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'حدث خطأ: ' . $e->getMessage())
                ->withInput();
        }
    }

    public function show(SalesInvoice $salesInvoice)
    {
        $salesInvoice->load('items.batch.medicine', 'branch', 'creator');
        return view('sales_invoices.show', compact('salesInvoice'));
    }

    public function edit(SalesInvoice $salesInvoice)
    {
        $formData = $this->salesInvoiceService->getEditFormData($salesInvoice);
        return view('sales_invoices.edit', $formData);
    }

    public function update(UpdateSalesInvoiceRequest $request, SalesInvoice $salesInvoice)
    {
        try {
            $this->salesInvoiceService->update($salesInvoice, $request->validated());
            return redirect()->route('sales-invoices.index')
                ->with('success', 'تم تعديل فاتورة المبيعات بنجاح.');
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'حدث خطأ: ' . $e->getMessage())
                ->withInput();
        }
    }

    public function destroy(SalesInvoice $salesInvoice)
    {
        try {
            $this->salesInvoiceService->delete($salesInvoice);
            return redirect()->route('sales-invoices.index')
                ->with('success', 'تم حذف فاتورة المبيعات وإرجاع الكميات للمخزون بنجاح.');
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'حدث خطأ أثناء حذف الفاتورة: ' . $e->getMessage());
        }
    }

    public function receipt(SalesInvoice $salesInvoice)
    {
        $salesInvoice->load('items.batch.medicine', 'branch', 'creator');
        return view('sales_invoices.receipt', compact('salesInvoice'));
    }

    public function print(SalesInvoice $salesInvoice)
    {
        $salesInvoice->load('items.batch.medicine', 'branch', 'creator');
        return view('sales_invoices.print', compact('salesInvoice'));
    }
}
