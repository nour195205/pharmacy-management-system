<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PurchaseInvoice extends Model
{
    protected $fillable = ['supplier_id', 'date', 'total', 'status', 'payment_method', 'notes', 'created_by'];

    public function supplier()
    {
        return $this->belongsTo(Supplier::class);
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function items()
    {
        return $this->hasMany(PurchaseInvoiceItem::class);
    }

    public function returns()
    {
        return $this->hasMany(PurchaseReturn::class);
    }
}
