<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CustomerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'           => $this->id,
            'name'         => $this->name,
            'phone'        => $this->phone,
            'address'      => $this->address,
            'credit_limit' => $this->credit_limit,
            'balance'      => $this->whenLoaded('account', fn() => $this->account->balance),
            'created_at'   => $this->created_at?->toISOString(),
        ];
    }
}
