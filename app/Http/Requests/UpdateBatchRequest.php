<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateBatchRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'medicine_id'      => 'required|exists:medicines,id',
            'branch_id'        => 'required|exists:branches,id',
            'batch_number'     => 'required|string|max:255',
            'manufacture_date' => 'required|date',
            'expiry_date'      => 'required|date|after_or_equal:manufacture_date',
            'quantity'         => 'required|numeric|min:0',
            'purchase_price'   => 'required|numeric|min:0',
            'selling_price'    => 'required|numeric|min:0',
        ];
    }
}
