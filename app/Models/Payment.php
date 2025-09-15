<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $fillable = ['invoice_id', 'type', 'amount', 'date', 'method'];

    // لو هتعمل polymorphic علشان تغطي المشتريات والمبيعات:
    public function invoice()
    {
        return $this->morphTo();
    }
}
