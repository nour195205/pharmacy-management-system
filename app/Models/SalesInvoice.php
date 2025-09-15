<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SalesInvoice extends Model
{
    protected $fillable = ['branch_id', 'date', 'total', 'created_by'];

    public function branch()
    {
        return $this->belongsTo(Branch::class);
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function items()
    {
        return $this->hasMany(SalesInvoiceItem::class);
    }

    public function returns()
    {
        return $this->hasMany(SalesReturn::class);
    }
}
