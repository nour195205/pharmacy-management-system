<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    protected $fillable = [
        'title',        // عنوان التنبيه
        'message',      // محتوى التنبيه
        'type',         // نوع التنبيه: تحذير / معلومة / تنبيه
        'expires_at'    // اختياري: لو عايز التنبيه يختفي بعد وقت معين
    ];

    protected $dates = ['expires_at']; // عشان Laravel يتعامل مع التاريخ كويس

    /**
     * جلب التنبيهات الحالية فقط (اللي لم تنتهي بعد)
     */
    public function scopeActive($query)
    {
        return $query->where(function($q){
            $q->whereNull('expires_at')
              ->orWhere('expires_at', '>', now());
        });
    }
}
