<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreSalesReturnRequest;
use App\Http\Resources\SalesReturnResource;
use App\Models\SalesReturn;
use App\Services\SalesReturnService;
use App\Traits\ApiResponse;

class SalesReturnController extends Controller
{
    use ApiResponse;

    public function __construct(private SalesReturnService $salesReturnService) {}

    public function index()
    {
        $returns = $this->salesReturnService->getPaginated();
        return SalesReturnResource::collection($returns);
    }

    public function store(StoreSalesReturnRequest $request)
    {
        try {
            $userId = auth()->id() ?? 1;
            $salesReturn = $this->salesReturnService->store($request->validated(), $userId);
            $salesReturn->load('items.batch.medicine', 'salesInvoice.branch', 'creator');
            
            return $this->created(
                new SalesReturnResource($salesReturn),
                'تم إضافة فاتورة مرتجع المبيعات بنجاح'
            );
        } catch (\Exception $e) {
            return $this->error('حدث خطأ أثناء إرجاع الفاتورة: ' . $e->getMessage(), 422);
        }
    }

    public function show(SalesReturn $salesReturn)
    {
        $salesReturn->load('items.batch.medicine', 'salesInvoice.branch', 'creator');
        return $this->success(new SalesReturnResource($salesReturn));
    }
}
