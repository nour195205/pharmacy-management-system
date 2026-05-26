<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreSupplierRequest;
use App\Http\Requests\UpdateSupplierRequest;
use App\Http\Resources\SupplierResource;
use App\Models\Supplier;
use App\Services\SupplierService;
use App\Traits\ApiResponse;

class SupplierController extends Controller
{
    use ApiResponse;

    public function __construct(private SupplierService $supplierService) {}

    public function index()
    {
        return $this->success(
            SupplierResource::collection($this->supplierService->getAll()),
            'تم جلب الموردين بنجاح'
        );
    }

    public function store(StoreSupplierRequest $request)
    {
        $supplier = $this->supplierService->create($request->validated());
        return $this->created(new SupplierResource($supplier), 'تم إضافة المورد بنجاح');
    }

    public function show(Supplier $supplier)
    {
        return $this->success(new SupplierResource($supplier));
    }

    public function update(UpdateSupplierRequest $request, Supplier $supplier)
    {
        $supplier = $this->supplierService->update($supplier, $request->validated());
        return $this->success(new SupplierResource($supplier), 'تم تعديل المورد بنجاح');
    }

    public function destroy(Supplier $supplier)
    {
        $this->supplierService->delete($supplier);
        return $this->success(null, 'تم حذف المورد بنجاح');
    }
}
