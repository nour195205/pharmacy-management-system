<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BatchResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'               => $this->id,
            'batch_number'     => $this->batch_number,
            'manufacture_date' => $this->manufacture_date,
            'expiry_date'      => $this->expiry_date,
            'quantity'         => $this->quantity,
            'purchase_price'   => $this->purchase_price,
            'selling_price'    => $this->selling_price,
            'medicine'         => new MedicineResource($this->whenLoaded('medicine')),
            'branch'           => new BranchResource($this->whenLoaded('branch')),
            'created_at'       => $this->created_at?->toISOString(),
        ];
    }
}
