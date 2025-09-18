<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SalesInvoice extends Model
{
    use HasFactory;

    protected $fillable = [
        'branch_id',
        'customer_id',
        'date',
        'total',
        'status',
        'payment_method',
        'note',
        'created_by',
    ];

    public function branch()
    {
        return $this->belongsTo(Branch::class);
    }

    public function items()
    {
        return $this->hasMany(SalesInvoiceItem::class);
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
    public function returns()
    {
        return $this->hasMany(SalesReturn::class);
    }

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }
}