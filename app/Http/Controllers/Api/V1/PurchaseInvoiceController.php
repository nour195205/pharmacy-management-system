<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StorePurchaseInvoiceRequest;
use App\Http\Requests\UpdatePurchaseInvoiceRequest;
use App\Http\Resources\PurchaseInvoiceResource;
use App\Models\PurchaseInvoice;
use App\Services\PurchaseInvoiceService;
use App\Traits\ApiResponse;

class PurchaseInvoiceController extends Controller
{
    use ApiResponse;

    public function __construct(private PurchaseInvoiceService $purchaseInvoiceService) {}

    public function index()
    {
        $invoices = $this->purchaseInvoiceService->getPaginated();
        return PurchaseInvoiceResource::collection($invoices);
    }

    public function store(StorePurchaseInvoiceRequest $request)
    {
        try {
            $invoice = $this->purchaseInvoiceService->store($request->validated(), auth()->id());
            $invoice->load('items.batch.medicine', 'branch', 'supplier');
            return $this->created(
                new PurchaseInvoiceResource($invoice),
                'تم إضافة فاتورة المشتريات بنجاح'
            );
        } catch (\Exception $e) {
            return $this->error('حدث خطأ أثناء حفظ الفاتورة: ' . $e->getMessage(), 422);
        }
    }

    public function show(PurchaseInvoice $purchaseInvoice)
    {
        $purchaseInvoice->load('items.batch.medicine', 'branch', 'supplier', 'user');
        return $this->success(new PurchaseInvoiceResource($purchaseInvoice));
    }

    public function update(UpdatePurchaseInvoiceRequest $request, PurchaseInvoice $purchaseInvoice)
    {
        try {
            $invoice = $this->purchaseInvoiceService->update($purchaseInvoice, $request->validated());
            $invoice->load('items.batch.medicine', 'branch', 'supplier');
            return $this->success(
                new PurchaseInvoiceResource($invoice),
                'تم تعديل فاتورة المشتريات بنجاح'
            );
        } catch (\Exception $e) {
            return $this->error('حدث خطأ أثناء تعديل الفاتورة: ' . $e->getMessage(), 422);
        }
    }

    public function destroy(PurchaseInvoice $purchaseInvoice)
    {
        try {
            $this->purchaseInvoiceService->delete($purchaseInvoice);
            return $this->success(null, 'تم حذف فاتورة المشتريات بنجاح');
        } catch (\Exception $e) {
            return $this->error('حدث خطأ أثناء حذف الفاتورة: ' . $e->getMessage(), 422);
        }
    }
}
