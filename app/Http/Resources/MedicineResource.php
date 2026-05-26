<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MedicineResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'            => $this->id,
            'name'          => $this->name,
            'category'      => $this->category,
            'description'   => $this->description,
            'barcode'       => $this->barcode,
            'unit'          => $this->unit,
            'price'         => $this->price,
            'reorder_level' => $this->reorder_level,
            'is_active'     => $this->is_active,
            'created_at'    => $this->created_at?->toISOString(),
        ];
    }
}
