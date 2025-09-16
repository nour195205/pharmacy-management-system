<?php

use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BranchController;
use App\Http\Controllers\SupplierController;
use App\Http\Controllers\MedicineController;
use App\Http\Controllers\BatchController;

Route::get('/', function () {  
    return view('welcome');
});

Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

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



Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

});

require __DIR__.'/auth.php';
