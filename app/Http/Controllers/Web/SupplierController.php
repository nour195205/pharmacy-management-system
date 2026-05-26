<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreSupplierRequest;
use App\Http\Requests\UpdateSupplierRequest;
use App\Models\Supplier;
use App\Services\SupplierService;

class SupplierController extends Controller
{
    public function __construct(private SupplierService $supplierService) {}

    public function index()
    {
        $suppliers = $this->supplierService->getAll();
        return view('suppliers.index', compact('suppliers'));
    }

    public function create()
    {
        return view('suppliers.create');
    }

    public function store(StoreSupplierRequest $request)
    {
        $this->supplierService->create($request->validated());
        return redirect()->route('suppliers.index')->with('success', 'تم إضافة المورد بنجاح.');
    }

    public function edit(Supplier $supplier)
    {
        return view('suppliers.edit', compact('supplier'));
    }

    public function update(UpdateSupplierRequest $request, Supplier $supplier)
    {
        $this->supplierService->update($supplier, $request->validated());
        return redirect()->route('suppliers.index');
    }

    public function destroy(Supplier $supplier)
    {
        $this->supplierService->delete($supplier);
        return to_route('suppliers.index')->with('success', 'تم حذف المورد بنجاح!');
    }
}
