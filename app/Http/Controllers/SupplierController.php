<?php

namespace App\Http\Controllers;
use App\Models\Supplier;

use Illuminate\Http\Request;

class SupplierController extends Controller
{
    public function index()
    {
        $suppliers = Supplier::all();
        return view('suppliers.index', ['suppliers' => $suppliers]);
    }

    public function create()
    {
        return view('suppliers.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'contact_info' => 'nullable|string|max:255',
            'address' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:50',
            'email' => 'nullable|email|max:255',
            'balance' => 'nullable|integer|min:0',
        ]);

        Supplier::create($request->all());

        return redirect()->route('suppliers.index')->with('success', 'تم إضافة المورد بنجاح.');
    }

    public function edit(Supplier $supplier)
    {
        return view('suppliers.edit', ['supplier' => $supplier]);
    }

    public function update(Request $request, $supplierId)
    {
        $singlePostfromDB = Supplier::find($supplierId);

        $singlePostfromDB->update([
            'name' => $request->input('name'),
            'contact_info' => $request->input('contact_info'),
            'address' => $request->input('address'),
            'phone' => $request->input('phone'),
            'email' => $request->input('email'),
            'balance' => $request->input('balance'),
        ]);

        return redirect()->route('suppliers.index', $supplierId);
    }


    public function destroy($supplierId)
    {
        $supplier = Supplier::find($supplierId);
        $supplier->delete();
        // Logic to delete the post
        return to_route('suppliers.index')->with('success', 'supplier deleted successfully!');
    }
}
