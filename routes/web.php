<?php

use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BranchController;
use App\Http\Controllers\SupplierController;
use App\Http\Controllers\MedicineController;
use App\Http\Controllers\BatchController;
use App\Http\Controllers\SalesInvoiceController;
use App\Http\Controllers\PurchaseReturnController;
use App\Http\Controllers\SalesReturnController;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\PurchaseInvoiceController;
use App\Http\Controllers\ReportController;


Route::middleware('auth')->group(function () {

    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('welcome'); // مسار إضافي للداش بورد

    Route::get('/branches', [BranchController::class, 'index'])->name('branches.index');
    Route::get('/branches/create', [BranchController::class, 'create'])->name('branches.create');
    Route::get('/branches/{branch}/edit', [BranchController::class, 'edit'])->name('branches.edit');
    Route::delete('/branches/{branch}', [BranchController::class, 'destroy'])->name('branches.destroy');
    Route::put('/branches/{branch}', [BranchController::class, 'update'])->name('branches.update');
    Route::post('/branches', [BranchController::class, 'store'])->name('branches.store');

    Route::get('/suppliers', [SupplierController::class, 'index'])->name('suppliers.index');
    Route::get('/suppliers/create', [SupplierController::class, 'create'])->name('suppliers.create');
    Route::get('/suppliers/{supplier}/edit', [SupplierController::class, 'edit'])->name('suppliers.edit');
    Route::delete('/suppliers/{supplier}', [SupplierController::class, 'destroy'])->name('suppliers.destroy');
    Route::put('/suppliers/{supplier}', [SupplierController::class, 'update'])->name('suppliers.update');
    Route::post('/suppliers', [SupplierController::class, 'store'])->name('suppliers.store');

    Route::get('/medicines', [MedicineController::class, 'index'])->name('medicines.index');
    Route::get('/medicines/create', [MedicineController::class, 'create'])->name('medicines.create');
    Route::get('/medicines/{medicine}', [MedicineController::class, 'show'])->name('medicines.show');
    Route::get('/medicines/{medicine}/edit', [MedicineController::class, 'edit'])->name('medicines.edit');
    Route::delete('/medicines/{medicine}', [MedicineController::class, 'destroy'])->name('medicines.destroy');
    Route::put('/medicines/{medicine}', [MedicineController::class, 'update'])->name('medicines.update');
    Route::post('/medicines', [MedicineController::class, 'store'])->name('medicines.store');

    Route::get('/batches', [BatchController::class, 'index'])->name('batches.index');
    Route::get('/batches/create', [BatchController::class, 'create'])->name('batches.create');
    Route::get('/batches/{batch}', [BatchController::class, 'show'])->name('batches.show');
    Route::get('/batches/{batch}/edit', [BatchController::class, 'edit'])->name('batches.edit');
    Route::delete('/batches/{batch}', [BatchController::class, 'destroy'])->name('batches.destroy');
    Route::put('/batches/{batch}', [BatchController::class, 'update'])->name('batches.update');
    Route::post('/batches', [BatchController::class, 'store'])->name('batches.store');

    Route::resource('purchase-invoices', PurchaseInvoiceController::class);
    Route::get('purchase-invoices/{purchaseInvoice}/print', [PurchaseInvoiceController::class, 'print'])->name('purchase-invoices.print');

    Route::resource('purchase-returns', PurchaseReturnController::class);

    Route::resource('sales-invoices', SalesInvoiceController::class);
    Route::get('sales-invoices/{salesInvoice}/print', [SalesInvoiceController::class, 'print'])->name('sales-invoices.print');
    Route::get('sales-invoices/{salesInvoice}/receipt', [App\Http\Controllers\SalesInvoiceController::class, 'receipt'])->name('sales-invoices.receipt');

    Route::resource('sales-returns', SalesReturnController::class);
    Route::get('sales-returns/{salesReturn}/receipt', [SalesReturnController::class, 'receipt'])->name('sales-returns.receipt');

    Route::resource('customers', CustomerController::class);

    Route::get('/customers/{customer}/payments/create', [PaymentController::class, 'create'])->name('customers.payments.create');
    Route::post('/customers/{customer}/payments', [PaymentController::class, 'store'])->name('customers.payments.store');

    Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
    Route::post('/reports/generate', [ReportController::class, 'generate'])->name('reports.generate');
    Route::get('/reports/{report}/download', [ReportController::class, 'download'])->name('reports.download');
});

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

});

require __DIR__ . '/auth.php';
