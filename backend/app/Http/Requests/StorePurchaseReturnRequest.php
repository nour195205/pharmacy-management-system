<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePurchaseReturnRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'purchase_invoice_id'  => 'required|exists:purchase_invoices,id',
            'date'                 => 'required|date',
            'reason'               => 'nullable|string',
            'items'                => 'required|array',
            'items.*.batch_id'     => 'required|exists:batches,id',
            'items.*.quantity'     => 'nullable|integer|min:0',
        ];
    }
}
