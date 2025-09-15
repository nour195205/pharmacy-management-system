<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Medicine extends Model
{
    // $table->string('name');
    // $table->string('category');
    // $table->text('description');
    // $table->string('barcode');
    // $table->enum('unit' , ['شريط','علبه','زجاجه']);
    // $table->integer('price');
    // $table->string('reorder_level');
    // $table->boolean('is_active');
    protected $fillable = ['name', 'category', 'description', 'barcode' , 'unit', 'price', 'reorder_level', 'is_active'];

    public function batches()
    {
        return $this->hasMany(Batch::class);
    }
}
