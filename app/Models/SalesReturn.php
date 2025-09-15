<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SalesReturn extends Model
{
    protected $fillable = ['sales_invoice_id', 'date', 'total'];

    public function invoice()
    {
        return $this->belongsTo(SalesInvoice::class);
    }
}
