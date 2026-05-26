<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PurchaseReturnResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'                  => $this->id,
            'date'                => $this->date,
            'total'               => $this->total,
            'reason'              => $this->reason,
            'purchase_invoice'    => new PurchaseInvoiceResource($this->whenLoaded('purchaseInvoice')),
            'user'                => $this->whenLoaded('user', function () {
                return ['id' => $this->user->id, 'name' => $this->user->name];
            }),
            'items'               => PurchaseReturnItemResource::collection($this->whenLoaded('items')),
            'created_at'          => $this->created_at?->toISOString(),
        ];
    }
}
