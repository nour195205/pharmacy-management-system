<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Medicine extends Model
{
    protected $fillable = ['name', 'category', 'description', 'barcode'];

    public function batches()
    {
        return $this->hasMany(Batch::class);
    }
}
