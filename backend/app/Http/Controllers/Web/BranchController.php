<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBranchRequest;
use App\Http\Requests\UpdateBranchRequest;
use App\Models\Branch;
use App\Services\BranchService;

class BranchController extends Controller
{
    public function __construct(private BranchService $branchService) {}

    public function index()
    {
        $branches = $this->branchService->getAll();
        return view('branches.index', compact('branches'));
    }

    public function create()
    {
        return view('branches.create');
    }

    public function store(StoreBranchRequest $request)
    {
        $this->branchService->create($request->validated());
        return redirect()->route('branches.create')->with('success', 'تم إضافة الفرع بنجاح!');
    }

    public function edit(Branch $branch)
    {
        return view('branches.edit', compact('branch'));
    }

    public function update(UpdateBranchRequest $request, Branch $branch)
    {
        $this->branchService->update($branch, $request->validated());
        return redirect()->route('branches.index');
    }

    public function destroy(Branch $branch)
    {
        $this->branchService->delete($branch);
        return to_route('branches.index')->with('success', 'تم حذف الفرع بنجاح!');
    }
}
