<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBranchRequest;
use App\Http\Requests\UpdateBranchRequest;
use App\Http\Resources\BranchResource;
use App\Models\Branch;
use App\Services\BranchService;
use App\Traits\ApiResponse;

class BranchController extends Controller
{
    use ApiResponse;

    public function __construct(private BranchService $branchService) {}

    public function index()
    {
        return $this->success(
            BranchResource::collection($this->branchService->getAll()),
            'تم جلب الفروع بنجاح'
        );
    }

    public function store(StoreBranchRequest $request)
    {
        $branch = $this->branchService->create($request->validated());
        return $this->created(new BranchResource($branch), 'تم إضافة الفرع بنجاح');
    }

    public function show(Branch $branch)
    {
        return $this->success(new BranchResource($branch));
    }

    public function update(UpdateBranchRequest $request, Branch $branch)
    {
        $branch = $this->branchService->update($branch, $request->validated());
        return $this->success(new BranchResource($branch), 'تم تعديل الفرع بنجاح');
    }

    public function destroy(Branch $branch)
    {
        $this->branchService->delete($branch);
        return $this->success(null, 'تم حذف الفرع بنجاح');
    }
}
