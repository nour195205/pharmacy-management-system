<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateCustomerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name'         => 'required|string|max:255',
            'phone'        => ['nullable', 'string', Rule::unique('customers')->ignore($this->route('customer'))],
            'address'      => 'nullable|string',
            'credit_limit' => 'nullable|numeric|min:0',
        ];
    }
}
