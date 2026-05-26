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
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->string('invoice_id');
            $table->enum('type' , ['مشتريات' , 'مبيعات']);
            $table->integer('amount');
            $table->date('date');
            $table->enum('method', ['نقدا' , 'بطاقة' , 'أخرى']);
            $table->timestamps();
        });

    }


};
