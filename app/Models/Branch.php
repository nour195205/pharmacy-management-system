<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Branch extends Model
{
    protected $fillable = ['name', 'location'];

    public function stores()
    {
        return $this->hasMany(Store::class);
    }

    public function salesInvoices()
    {
        return $this->hasMany(SalesInvoice::class);
    }
}
