<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePurchaseInvoiceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'branch_id'                 => 'required|exists:branches,id',
            'supplier_id'               => 'required|exists:suppliers,id',
            'invoice_date'              => 'required|date',
            'items'                     => 'required|array|min:1',
            'items.*.medicine_id'       => 'required|exists:medicines,id',
            'items.*.quantity'          => 'required|integer|min:1',
            'items.*.purchase_price'    => 'required|numeric|min:0',
            'items.*.selling_price'     => 'required|numeric|min:0|gt:items.*.purchase_price',
            'items.*.manufacture_date'  => 'required|date',
            'items.*.expiry_date'       => 'required|date|after:items.*.manufacture_date',
        ];
    }
}
