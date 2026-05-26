<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBatchRequest;
use App\Http\Requests\UpdateBatchRequest;
use App\Models\Batch;
use App\Services\BatchService;

class BatchController extends Controller
{
    public function __construct(private BatchService $batchService) {}

    public function index()
    {
        $batches = $this->batchService->getAll();
        return view('batches.index', compact('batches'));
    }

    public function create()
    {
        $formData = $this->batchService->getFormData();
        return view('batches.create', $formData);
    }

    public function store(StoreBatchRequest $request)
    {
        $this->batchService->create($request->validated());
        return redirect()->route('batches.index')->with('success', 'تمت إضافة التشغيلة بنجاح.');
    }

    public function show(Batch $batch)
    {
        return view('batches.show', compact('batch'));
    }

    public function edit(Batch $batch)
    {
        $formData = $this->batchService->getFormData();
        return view('batches.edit', array_merge(['batch' => $batch], $formData));
    }

    public function update(UpdateBatchRequest $request, Batch $batch)
    {
        $this->batchService->update($batch, $request->validated());
        return redirect()->route('batches.index')->with('success', 'تم تحديث التشغيلة بنجاح.');
    }

    public function destroy(Batch $batch)
    {
        $this->batchService->delete($batch);
        return redirect()->route('batches.index')->with('success', 'تم حذف التشغيلة بنجاح.');
    }
}
