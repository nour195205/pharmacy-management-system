<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PurchaseReturn extends Model
{
    protected $fillable = ['purchase_invoice_id', 'date', 'total'];

    public function invoice()
    {
        return $this->belongsTo(PurchaseInvoice::class);
    }
}
