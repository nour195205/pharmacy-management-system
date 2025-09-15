<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Batch extends Model
{
    protected $fillable = [
        'medicine_id', 'batch_number', 'manufacture_date',
        'expiry_date', 'quantity', 'purchase_price', 'selling_price', 'branch_id'
    ];

    public function medicine()
    {
        return $this->belongsTo(Medicine::class);
    }

    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    public function purchaseInvoiceItems()
    {
        return $this->hasMany(PurchaseInvoiceItem::class);
    }

    public function salesInvoiceItems()
    {
        return $this->hasMany(SalesInvoiceItem::class);
    }
}

