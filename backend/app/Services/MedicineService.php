<?php

namespace App\Services;

use App\Models\Medicine;
use Illuminate\Database\Eloquent\Collection;

class MedicineService
{
    public function getAll(): Collection
    {
        return Medicine::all();
    }

    public function find(int $id): ?Medicine
    {
        return Medicine::find($id);
    }

    public function create(array $data): Medicine
    {
        return Medicine::create($data);
    }

    public function update(Medicine $medicine, array $data): Medicine
    {
        $medicine->update($data);
        return $medicine->fresh();
    }

    public function delete(Medicine $medicine): void
    {
        $medicine->delete();
    }
}
