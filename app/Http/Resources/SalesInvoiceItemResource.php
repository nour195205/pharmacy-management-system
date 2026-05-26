<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SalesInvoiceItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'       => $this->id,
            'quantity' => $this->qty,
            'price'    => $this->price,
            'total'    => $this->total,
            'batch'    => new BatchResource($this->whenLoaded('batch')),
        ];
    }
}
