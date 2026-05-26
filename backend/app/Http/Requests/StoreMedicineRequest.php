<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreMedicineRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name'          => 'required|string|max:255',
            'category'      => 'nullable|string|max:255',
            'description'   => 'nullable|string',
            'barcode'       => 'nullable|string|max:255',
            'unit'          => 'required|in:شريط,علبه,زجاجه',
            'price'         => 'required|integer|min:0',
            'reorder_level' => 'nullable|string|max:255',
            'is_active'     => 'boolean',
        ];
    }
}
