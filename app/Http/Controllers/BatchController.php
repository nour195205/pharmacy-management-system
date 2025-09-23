<?php

namespace App\Http\Controllers;

use App\Models\Batch;
use App\Models\Medicine;
use App\Models\Branch;
use Illuminate\Http\Request;

class BatchController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $batches = Batch::with(['medicine', 'branch'])->latest()->get();
        return view('batches.index', compact('batches'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        $medicines = Medicine::all();
        $branches = Branch::all();
        return view('batches.create', compact('medicines', 'branches'));
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'medicine_id' => 'required|exists:medicines,id',
            'branch_id' => 'required|exists:branches,id',
            'batch_number' => 'required|string|max:255',
            'manufacture_date' => 'required|date',
            'expiry_date' => 'required|date|after_or_equal:manufacture_date',
            'quantity' => 'required|numeric|min:0',
            'purchase_price' => 'required|numeric|min:0',
            'selling_price' => 'required|numeric|min:0',
        ]);

        Batch::create($request->all());

        return redirect()->route('batches.index')
                         ->with('success', 'تمت إضافة التشغيلة بنجاح.');
    }

    /**
     * Display the specified resource.
     */
    public function show(Batch $batch)
    {
        return view('batches.show', compact('batch'));
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Batch $batch)
    {
        $medicines = Medicine::all();
        $branches = Branch::all();
        return view('batches.edit', compact('batch', 'medicines', 'branches'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Batch $batch)
    {
        // 1. التحقق من صحة البيانات المدخلة
        $validatedData = $request->validate([
            'medicine_id' => 'required|exists:medicines,id',
            'branch_id' => 'required|exists:branches,id',
            'batch_number' => 'required|string|max:255',
            'manufacture_date' => 'required|date',
            'expiry_date' => 'required|date|after_or_equal:manufacture_date',
            'quantity' => 'required|numeric|min:0',
            'purchase_price' => 'required|numeric|min:0',
            'selling_price' => 'required|numeric|min:0',
        ]);

        // 2. تحديث البيانات باستخدام البيانات التي تم التحقق منها فقط
        $batch->update($validatedData);

        // 3. إعادة التوجيه مع رسالة نجاح
        return redirect()->route('batches.index')
                         ->with('success', 'تم تحديث التشغيلة بنجاح.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Batch $batch)
    {
        $batch->delete();
        return redirect()->route('batches.index')
                         ->with('success', 'تم حذف التشغيلة بنجاح.');
    }
}