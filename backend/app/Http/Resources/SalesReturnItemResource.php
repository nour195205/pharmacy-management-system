<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SalesReturnItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'            => $this->id,
            'quantity'      => $this->quantity,
            'selling_price' => $this->selling_price,
            'total'         => $this->total,
            'batch'         => new BatchResource($this->whenLoaded('batch')),
        ];
    }
}
