<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StorePurchaseReturnRequest;
use App\Http\Resources\PurchaseReturnResource;
use App\Models\PurchaseReturn;
use App\Services\PurchaseReturnService;
use App\Traits\ApiResponse;

class PurchaseReturnController extends Controller
{
    use ApiResponse;

    public function __construct(private PurchaseReturnService $purchaseReturnService) {}

    public function index()
    {
        $returns = $this->purchaseReturnService->getPaginated();
        return PurchaseReturnResource::collection($returns);
    }

    public function store(StorePurchaseReturnRequest $request)
    {
        try {
            // Using auth()->id() fallback to 1 if testing without token
            $userId = auth()->id() ?? 1;
            $purchaseReturn = $this->purchaseReturnService->store($request->validated(), $userId);
            $purchaseReturn->load('items.batch.medicine', 'purchaseInvoice.supplier', 'user');
            
            return $this->created(
                new PurchaseReturnResource($purchaseReturn),
                'تم إضافة فاتورة مرتجع المشتريات بنجاح'
            );
        } catch (\Exception $e) {
            return $this->error('حدث خطأ أثناء إرجاع الفاتورة: ' . $e->getMessage(), 422);
        }
    }

    public function show(PurchaseReturn $purchaseReturn)
    {
        $purchaseReturn->load('items.batch.medicine', 'purchaseInvoice.supplier', 'user');
        return $this->success(new PurchaseReturnResource($purchaseReturn));
    }
}
