<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PurchaseInvoiceResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'           => $this->id,
            'invoice_date' => $this->invoice_date,
            'total_amount' => $this->total_amount,
            'branch'       => new BranchResource($this->whenLoaded('branch')),
            'supplier'     => new SupplierResource($this->whenLoaded('supplier')),
            'items'        => PurchaseInvoiceItemResource::collection($this->whenLoaded('items')),
            'created_at'   => $this->created_at?->toISOString(),
        ];
    }
}
