<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreCustomerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name'         => 'required|string|max:255',
            'phone'        => 'nullable|string|unique:customers,phone',
            'address'      => 'nullable|string',
            'credit_limit' => 'nullable|numeric|min:0',
        ];
    }
}
