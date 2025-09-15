<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Schema::create('flights', function (Blueprint $table) {
        //     $table->id();
        //     $table->foreignId('medicine_id')->constrained()->onDelete('cascade');
        //     $table->integer('batch_number');
        //     $table->date('manufacture_date');
        //     $table->date('expiry_date');
        //     $table->integer('quantity');
        //     $table->integer('purchase_price');
        //     $table->integer('selling_price');
        //     $table->foreignId('store_id')->constrained()->onDelete('cascade');
        // });


        Schema::create('batches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('medicine_id')->constrained()->onDelete('cascade');
            $table->integer('batch_number');
            $table->date('manufacture_date');
            $table->date('expiry_date');
            $table->integer('quantity');
            $table->integer('purchase_price');
            $table->integer('selling_price');
            $table->foreignId('store_id')->constrained()->onDelete('cascade');
            $table->timestamps();
        });

    }


};
