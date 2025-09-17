<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    // public function up(): void
    // {
    //     Schema::create('purchase_invoices', function (Blueprint $table) {
    //         $table->id();
    //         $table->foreignId('supplier_id')->constrained()->onDelete('cascade');
    //         $table->date('date');
    //         $table->integer('total');
    //         $table->enum('status' , [ 'مدفوع' , 'معلق'  , 'ملغى']);
    //         $table->enum('payment_method' , [ 'نقدا' , 'بطاقة' , 'أخرى']);
    //         $table->text('notes');
    //         $table->foreignId('created_by')->constrained('users')->onDelete('cascade');


    //         $table->timestamps();
    //     });

    // }

    public function up(): void
    {
        Schema::create('purchase_invoices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('branch_id')->constrained('branches')->onDelete('cascade');
            $table->foreignId('supplier_id')->constrained('suppliers')->onDelete('cascade');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade'); // <-- أضف هذا السطر
            $table->date('invoice_date');
            $table->decimal('total_amount', 10, 2);
            $table->timestamps();
        });
    }
};
