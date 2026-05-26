<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreSalesInvoiceRequest;
use App\Http\Requests\UpdateSalesInvoiceRequest;
use App\Http\Resources\SalesInvoiceResource;
use App\Models\SalesInvoice;
use App\Services\SalesInvoiceService;
use App\Traits\ApiResponse;

class SalesInvoiceController extends Controller
{
    use ApiResponse;

    public function __construct(private SalesInvoiceService $salesInvoiceService) {}

    public function index()
    {
        $invoices = $this->salesInvoiceService->getPaginated();
        return SalesInvoiceResource::collection($invoices);
    }

    public function store(StoreSalesInvoiceRequest $request)
    {
        try {
            $invoice = $this->salesInvoiceService->store($request->validated(), auth()->id());
            $invoice->load('items.batch.medicine', 'branch', 'customer');
            return $this->created(
                new SalesInvoiceResource($invoice),
                'تم تسجيل فاتورة المبيعات بنجاح'
            );
        } catch (\Exception $e) {
            return $this->error('حدث خطأ: ' . $e->getMessage(), 422);
        }
    }

    public function show(SalesInvoice $salesInvoice)
    {
        $salesInvoice->load('items.batch.medicine', 'branch', 'creator', 'customer');
        return $this->success(new SalesInvoiceResource($salesInvoice));
    }

    public function update(UpdateSalesInvoiceRequest $request, SalesInvoice $salesInvoice)
    {
        try {
            $invoice = $this->salesInvoiceService->update($salesInvoice, $request->validated());
            $invoice->load('items.batch.medicine', 'branch', 'customer');
            return $this->success(
                new SalesInvoiceResource($invoice),
                'تم تعديل فاتورة المبيعات بنجاح'
            );
        } catch (\Exception $e) {
            return $this->error('حدث خطأ: ' . $e->getMessage(), 422);
        }
    }

    public function destroy(SalesInvoice $salesInvoice)
    {
        try {
            $this->salesInvoiceService->delete($salesInvoice);
            return $this->success(null, 'تم حذف فاتورة المبيعات بنجاح');
        } catch (\Exception $e) {
            return $this->error('حدث خطأ أثناء حذف الفاتورة: ' . $e->getMessage(), 422);
        }
    }
}
