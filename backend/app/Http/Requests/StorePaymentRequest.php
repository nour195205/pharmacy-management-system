<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $customer = $this->route('customer');
        $maxAmount = $customer && $customer->account ? $customer->account->balance : 0;

        return [
            'amount' => ['required', 'numeric', 'min:0.01', 'max:' . $maxAmount],
            'date'   => 'required|date',
            'notes'  => 'nullable|string',
        ];
    }
}
