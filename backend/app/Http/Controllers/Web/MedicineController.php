<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreMedicineRequest;
use App\Http\Requests\UpdateMedicineRequest;
use App\Models\Medicine;
use App\Services\MedicineService;

class MedicineController extends Controller
{
    public function __construct(private MedicineService $medicineService) {}

    public function index()
    {
        $medicines = $this->medicineService->getAll();
        return view('medicines.index', compact('medicines'));
    }

    public function show(int $medicineId)
    {
        $medicine = $this->medicineService->find($medicineId);

        if (is_null($medicine)) {
            return to_route('medicines.index')->with('error', 'medicine not found!');
        }

        return view('medicines.show', compact('medicine'));
    }

    public function create()
    {
        return view('medicines.create');
    }

    public function store(StoreMedicineRequest $request)
    {
        $this->medicineService->create($request->validated());
        return redirect()->route('medicines.index')->with('success', '✅ تم إضافة الدواء بنجاح');
    }

    public function edit(Medicine $medicine)
    {
        return view('medicines.edit', compact('medicine'));
    }

    public function update(UpdateMedicineRequest $request, Medicine $medicine)
    {
        $this->medicineService->update($medicine, $request->validated());
        return redirect()->route('medicines.index')->with('success', '✏️ تم تعديل بيانات الدواء بنجاح');
    }

    public function destroy(Medicine $medicine)
    {
        $this->medicineService->delete($medicine);
        return redirect()->route('medicines.index')->with('success', '🗑️ تم حذف الدواء بنجاح');
    }
}
