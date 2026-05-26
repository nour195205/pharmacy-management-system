<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBatchRequest;
use App\Http\Requests\UpdateBatchRequest;
use App\Http\Resources\BatchResource;
use App\Models\Batch;
use App\Services\BatchService;
use App\Traits\ApiResponse;

class BatchController extends Controller
{
    use ApiResponse;

    public function __construct(private BatchService $batchService) {}

    public function index()
    {
        return $this->success(
            BatchResource::collection($this->batchService->getAll()),
            'تم جلب التشغيلات بنجاح'
        );
    }

    public function store(StoreBatchRequest $request)
    {
        $batch = $this->batchService->create($request->validated());
        return $this->created(new BatchResource($batch->load('medicine', 'branch')), 'تم إضافة التشغيلة بنجاح');
    }

    public function show(Batch $batch)
    {
        return $this->success(new BatchResource($batch->load('medicine', 'branch')));
    }

    public function update(UpdateBatchRequest $request, Batch $batch)
    {
        $batch = $this->batchService->update($batch, $request->validated());
        return $this->success(new BatchResource($batch->load('medicine', 'branch')), 'تم تعديل التشغيلة بنجاح');
    }

    public function destroy(Batch $batch)
    {
        $this->batchService->delete($batch);
        return $this->success(null, 'تم حذف التشغيلة بنجاح');
    }
}
