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
    Schema::create('sales_return_items', function (Blueprint $table) {
        $table->id();
        $table->foreignId('sales_return_id')->constrained('sales_returns')->onDelete('cascade');
        $table->foreignId('batch_id')->constrained('batches')->onDelete('cascade'); // لنعرف أي دفعة تم الإرجاع إليها
        $table->decimal('quantity', 8, 2);
        $table->decimal('selling_price', 8, 2);
        $table->decimal('total', 10, 2);
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sales_return_items');
    }
};
