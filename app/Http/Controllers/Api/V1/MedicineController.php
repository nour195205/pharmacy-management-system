<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreMedicineRequest;
use App\Http\Requests\UpdateMedicineRequest;
use App\Http\Resources\MedicineResource;
use App\Models\Medicine;
use App\Services\MedicineService;
use App\Traits\ApiResponse;

class MedicineController extends Controller
{
    use ApiResponse;

    public function __construct(private MedicineService $medicineService) {}

    public function index()
    {
        return $this->success(
            MedicineResource::collection($this->medicineService->getAll()),
            'تم جلب الأدوية بنجاح'
        );
    }

    public function store(StoreMedicineRequest $request)
    {
        $medicine = $this->medicineService->create($request->validated());
        return $this->created(new MedicineResource($medicine), 'تم إضافة الدواء بنجاح');
    }

    public function show(Medicine $medicine)
    {
        return $this->success(new MedicineResource($medicine));
    }

    public function update(UpdateMedicineRequest $request, Medicine $medicine)
    {
        $medicine = $this->medicineService->update($medicine, $request->validated());
        return $this->success(new MedicineResource($medicine), 'تم تعديل الدواء بنجاح');
    }

    public function destroy(Medicine $medicine)
    {
        $this->medicineService->delete($medicine);
        return $this->success(null, 'تم حذف الدواء بنجاح');
    }
}
