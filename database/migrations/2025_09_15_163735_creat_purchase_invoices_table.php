<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('purchase_invoices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('supplier_id')->constrained()->onDelete('cascade');
            $table->date('date');
            $table->integer('total');
            $table->enum('status' , [ 'مدفوع' , 'معلق'  , 'ملغى']);
            $table->enum('payment_method' , [ 'نقدا' , 'بطاقة' , 'أخرى']);
            $table->text('notes');
            $table->foreignId('created_by')->constrained('users')->onDelete('cascade');

            
            $table->timestamps();
        });

    }


};
