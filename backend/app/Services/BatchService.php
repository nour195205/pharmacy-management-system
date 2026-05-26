<?php

namespace App\Services;

use App\Models\Batch;
use App\Models\Branch;
use App\Models\Medicine;
use Illuminate\Database\Eloquent\Collection;

class BatchService
{
    public function getAll(): Collection
    {
        return Batch::with(['medicine', 'branch'])->latest()->get();
    }

    public function getFormData(): array
    {
        return [
            'medicines' => Medicine::all(),
            'branches'  => Branch::all(),
        ];
    }

    public function create(array $data): Batch
    {
        return Batch::create($data);
    }

    public function update(Batch $batch, array $data): Batch
    {
        $batch->update($data);
        return $batch->fresh();
    }

    public function delete(Batch $batch): void
    {
        $batch->delete();
    }
}
