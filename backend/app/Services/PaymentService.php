<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Payment;
use Illuminate\Support\Facades\DB;

class PaymentService
{
    public function createPayment(Customer $customer, array $data): Payment
    {
        return DB::transaction(function () use ($customer, $data) {
            $payment = Payment::create([
                'customer_id' => $customer->id,
                'amount'      => $data['amount'],
                'date'        => $data['date'],
                'notes'       => $data['notes'] ?? null,
                'user_id'     => $data['user_id'],
            ]);

            $customer->account->decrement('balance', $data['amount']);

            return $payment;
        });
    }
}
