<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SalesReturnResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'               => $this->id,
            'date'             => $this->date,
            'total'            => $this->total,
            'reason'           => $this->reason,
            'sales_invoice'    => new SalesInvoiceResource($this->whenLoaded('salesInvoice')),
            'user'             => $this->whenLoaded('creator', function () {
                return ['id' => $this->creator->id, 'name' => $this->creator->name];
            }),
            'items'            => SalesReturnItemResource::collection($this->whenLoaded('items')),
            'created_at'       => $this->created_at?->toISOString(),
        ];
    }
}
