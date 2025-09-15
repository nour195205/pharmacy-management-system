<?php

use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BranchController;
use App\Http\Controllers\SupplierController;

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



Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

});

require __DIR__.'/auth.php';
