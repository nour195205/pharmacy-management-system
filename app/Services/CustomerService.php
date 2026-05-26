<?php

namespace App\Services;

use App\Models\Customer;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class CustomerService
{
    public function getPaginated(int $perPage = 15): LengthAwarePaginator
    {
        return Customer::with('account')->latest()->paginate($perPage);
    }

    public function getAll()
    {
        return Customer::all();
    }

    public function create(array $data): Customer
    {
        return DB::transaction(function () use ($data) {
            $customer = Customer::create($data);
            $customer->account()->create(['balance' => 0]);
            return $customer->load('account');
        });
    }

    public function update(Customer $customer, array $data): Customer
    {
        $customer->update($data);
        return $customer->fresh();
    }

    public function delete(Customer $customer): void
    {
        $customer->delete();
    }
}
