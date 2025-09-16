<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Batch extends Model
{
    use HasFactory;

    protected $fillable = [
        'medicine_id',
        'batch_number',
        'manufacture_date',
        'expiry_date',
        'quantity',
        'purchase_price',
        'selling_price',
        'branch_id',
    ];

    /**
     * العلاقة مع جدول الأدوية (Medicines)
     */
    public function medicine()
    {
        return $this->belongsTo(Medicine::class);
    }

    /**
     * العلاقة مع جدول الفروع (Branches)
     */
    public function branch()
    {
        return $this->belongsTo(Branch::class);
    }
}
