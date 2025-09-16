<?php

namespace App\Http\Controllers;

use App\Models\Medicine;
use Illuminate\Http\Request;

class MedicineController extends Controller
{
   
    public function index()
    {
        $medicines = Medicine::all();
        return view('medicines.index', compact('medicines'));
    }

    public function show($medicineId)
    {
        $singlePostfromDB = Medicine::find($medicineId);
        if (is_null($singlePostfromDB)) {
            return to_route('medicines.index')->with('error', 'medicine not found!');
        } else {
            return view('medicines.show', ['medicine' => $singlePostfromDB]);
        }
    }

    // 📌 صفحة إنشاء دواء جديد
    public function create()
    {
        return view('medicines.create');
    }

    // 📌 حفظ الدواء الجديد
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'barcode' => 'nullable|string|max:255',
            'unit' => 'required|in:شريط,علبه,زجاجه',
            'price' => 'required|integer|min:0',
            'reorder_level' => 'nullable|string|max:255',
            'is_active' => 'boolean',
        ]);

        Medicine::create($request->all());

        return redirect()->route('medicines.index')->with('success', '✅ تم إضافة الدواء بنجاح');
    }

    // 📌 صفحة تعديل دواء
    public function edit(Medicine $medicine)
    {
        return view('medicines.edit', compact('medicine'));
    }

    // 📌 تحديث بيانات الدواء
    public function update(Request $request, Medicine $medicine)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'barcode' => 'nullable|string|max:255',
            'unit' => 'required|in:شريط,علبه,زجاجه',
            'price' => 'required|integer|min:0',
            'reorder_level' => 'nullable|string|max:255',
            'is_active' => 'boolean',
        ]);

        $medicine->update($request->all());

        return redirect()->route('medicines.index')->with('success', '✏️ تم تعديل بيانات الدواء بنجاح');
    }

    // 📌 حذف دواء
    public function destroy(Medicine $medicine)
    {
        $medicine->delete();

        return redirect()->route('medicines.index')->with('success', '🗑️ تم حذف الدواء بنجاح');
    }
}