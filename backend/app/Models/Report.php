<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Report extends Model
{
    protected $fillable = ['report_date', 'file_path', 'type', 'total_sales', 'total_expenses'];
}
