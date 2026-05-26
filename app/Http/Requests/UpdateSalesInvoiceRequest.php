<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateSalesInvoiceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'branch_id'          => 'required|exists:branches,id',
            'customer_id'        => 'nullable|exists:customers,id',
            'date'               => 'required|date',
            'status'             => 'required|in:مدفوع,معلق,ملغى',
            'payment_method'     => 'required|in:نقدا,بطاقة,أخرى',
            'note'               => 'nullable|string',
            'items'              => 'required|array|min:1',
            'items.*.batch_id'   => 'required|exists:batches,id',
            'items.*.quantity'   => 'required|numeric|min:0.01',
        ];
    }
}
