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
        // Schema::create('purchase_invoice_items', function (Blueprint $table) {
        //     $table->id();
        //     $table->foreignId('purchase_invoice_id')->constrained('purchase_invoices')->onDelete('cascade');
        //     // $table->foreignId('batch_id')->constrained('batches')->onDelete('cascade');
        //     $table->unsignedBigInteger('batch_id');
        //     $table->foreign('batch_id')->references('id')->on('batches')->onDelete('cascade');

        //     $table->integer('qty');
        //     $table->integer('price');
        //     $table->timestamps();
        // });

        Schema::create('purchase_invoice_items', function (Blueprint $table) {
            $table->id();

            $table->foreignId('purchase_invoice_id')
                ->constrained('purchase_invoices')
                ->onDelete('cascade');

            $table->foreignId('batch_id')
                ->constrained('batches')
                ->onDelete('cascade');

            $table->integer('qty');
            $table->decimal('price', 10, 2);

            $table->timestamps();
        });



    }


};
