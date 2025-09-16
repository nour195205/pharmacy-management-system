<?php

namespace App\Http\Controllers;

use App\Models\Batch;
use App\Models\Medicine;
use App\Models\Branch;
use Illuminate\Http\Request;

class BatchController extends Controller
{
    /**
     * عرض كل التشغيلات
     */
    public function index()
    {
        $batches = Batch::with(['medicine', 'branch'])->get();
        return view('batches.index', compact('batches'));
    }

    /**
     * فورم إنشاء تشغيلة
     */
    public function create()
    {
        $medicines = Medicine::all();
        $branches = Branch::all();
        return view('batches.create', compact('medicines', 'branches'));
    }

    /**
     * حفظ تشغيلة جديدة
     */
    public function store(Request $request)
    {
        $request->validate([
            'medicine_id'     => 'required|exists:medicines,id',
            'batch_number'    => 'required|integer',
            'manufacture_date'=> 'required|date',
            'expiry_date'     => 'required|date|after:manufacture_date',
            'quantity'        => 'required|integer|min:1',
            'purchase_price'  => 'required|integer|min:0',
            'selling_price'   => 'required|integer|min:0',
            'branch_id'       => 'required|exists:branches,id',
        ]);

        Batch::create($request->all());

        return redirect()->route('batches.index')->with('success', 'تم إضافة التشغيلة بنجاح ✅');
    }

    /**
     * عرض تفاصيل تشغيلة
     */
    public function show(Batch $batch)
    {
        return view('batches.show', compact('batch'));
    }

    /**
     * فورم التعديل
     */
    public function edit(Batch $batch)
    {
        $medicines = Medicine::all();
        $branches = Branch::all();
        return view('batches.edit', compact('batch', 'medicines', 'branches'));
    }

    /**
     * تحديث تشغيلة
     */
    public function update(Request $request, Batch $batch)
    {
        $request->validate([
            'medicine_id'     => 'required|exists:medicines,id',
            'batch_number'    => 'required|integer',
            'manufacture_date'=> 'required|date',
            'expiry_date'     => 'required|date|after:manufacture_date',
            'quantity'        => 'required|integer|min:1',
            'purchase_price'  => 'required|integer|min:0',
            'selling_price'   => 'required|integer|min:0',
            'branch_id'       => 'required|exists:branches,id',
        ]);

        $batch->update($request->all());

        return redirect()->route('batches.index')->with('success', 'تم تحديث التشغيلة بنجاح ✏️');
    }

    /**
     * حذف تشغيلة
     */
    public function destroy(Batch $batch)
    {
        $batch->delete();
        return redirect()->route('batches.index')->with('success', 'تم حذف التشغيلة 🗑️');
    }
}
