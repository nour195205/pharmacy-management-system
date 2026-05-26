<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreSalesReturnRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'sales_invoice_id'         => 'required|exists:sales_invoices,id',
            'date'                     => 'required|date',
            'reason'                   => 'nullable|string',
            'items'                    => 'required|array',
            'items.*.sales_item_id'    => 'required|exists:sales_invoice_items,id',
            'items.*.quantity'         => 'nullable|numeric|min:0',
        ];
    }
}
