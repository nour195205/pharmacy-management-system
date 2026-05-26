<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SalesInvoiceResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'             => $this->id,
            'date'           => $this->date,
            'total'          => $this->total,
            'status'         => $this->status,
            'payment_method' => $this->payment_method,
            'note'           => $this->note,
            'branch'         => new BranchResource($this->whenLoaded('branch')),
            'customer'       => new CustomerResource($this->whenLoaded('customer')),
            'items'          => SalesInvoiceItemResource::collection($this->whenLoaded('items')),
            'created_at'     => $this->created_at?->toISOString(),
        ];
    }
}
