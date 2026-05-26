<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\BatchController;
use App\Http\Controllers\Api\V1\BranchController;
use App\Http\Controllers\Api\V1\CustomerController;
use App\Http\Controllers\Api\V1\DashboardController;
use App\Http\Controllers\Api\V1\MedicineController;
use App\Http\Controllers\Api\V1\PurchaseInvoiceController;
use App\Http\Controllers\Api\V1\SalesInvoiceController;
use App\Http\Controllers\Api\V1\SupplierController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| These routes are loaded by bootstrap/app.php and prefixed with /api.
| All API responses return JSON.
|
*/

Route::prefix('v1')->name('api.v1.')->group(function () {

    // Auth routes (public)
    Route::post('/login', [AuthController::class, 'login']);

    // Protected routes
    // TODO: Add auth:sanctum middleware when ready for production
    // Route::middleware('auth:sanctum')->group(function () {

        Route::post('/logout', [AuthController::class, 'logout']);

        Route::get('/dashboard', [DashboardController::class, 'index']);

        Route::apiResource('branches', BranchController::class);
        Route::apiResource('suppliers', SupplierController::class);
        Route::apiResource('medicines', MedicineController::class);
        Route::apiResource('batches', BatchController::class);
        Route::apiResource('customers', CustomerController::class);
        Route::apiResource('purchase-invoices', PurchaseInvoiceController::class);
        Route::apiResource('purchase-returns', \App\Http\Controllers\Api\V1\PurchaseReturnController::class)->only(['index', 'store', 'show']);
        Route::apiResource('sales-invoices', SalesInvoiceController::class);

    // });
});
