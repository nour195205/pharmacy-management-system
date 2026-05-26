<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PurchaseInvoice extends Model
{
    // use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */



    use HasFactory;
    
    // تأكد أن هذا الجزء موجود ومطابق
    protected $fillable = [
        'branch_id', // <-- أضف هذا
        'supplier_id', // <-- أضف هذا
        'user_id',
        'invoice_date',
        'total_amount',
        'qty',
        'price',
        'total',
    ];

    public function purchaseInvoice()
    {
        return $this->belongsTo(PurchaseInvoice::class);
    }

    public function batch()
    {
        return $this->belongsTo(Batch::class);
    }
    

    // ... باقي العلاقات زي ما هي ...

    public function supplier()
    {
        return $this->belongsTo(Supplier::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items()
    {
        return $this->hasMany(PurchaseInvoiceItem::class);
    }

    public function branch()
    {
        return $this->belongsTo(Branch::class);
    }

    public function returns()
{
    return $this->hasMany(PurchaseReturn::class);
}
}