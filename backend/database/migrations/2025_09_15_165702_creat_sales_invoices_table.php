<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {

    public function up(): void
    {
        Schema::create('sales_invoices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('branch_id')->constrained('branches')->onDelete('cascade');
            $table->date('date');
            $table->decimal('total', 10, 2); // الأفضل استخدام decimal للإجمالي
            $table->enum('status', ['مدفوع', 'معلق', 'ملغى'])->default('مدفوع');
            $table->enum('payment_method', ['نقدا', 'بطاقة', 'أخرى'])->default('نقدا');
            $table->text('note')->nullable();
            $table->foreignId('created_by')->constrained('users')->onDelete('cascade');
            $table->timestamps();
        });
    }
};
