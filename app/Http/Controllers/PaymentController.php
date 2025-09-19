<?php

namespace App\Http\Controllers;

use App\Models\Customer;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PaymentController extends Controller
{
    public function create(Customer $customer)
    {
        return view('payments.create', compact('customer'));
    }

    public function store(Request $request, Customer $customer)
    {
        $request->validate([
            'amount' => ['required', 'numeric', 'min:0.01', 'max:' . $customer->account->balance],
            'date' => 'required|date',
            'notes' => 'nullable|string',
        ]);

        DB::beginTransaction();
        try {
            // تسجيل عملية الدفع
            $payment = Payment::create([
                'customer_id' => $customer->id,
                'amount' => $request->amount,
                'date' => $request->date,
                'notes' => $request->notes,
                'user_id' => auth()->id(),
            ]);

            // خصم المبلغ من رصيد العميل
            $customer->account->decrement('balance', $request->amount);

            DB::commit();
            return redirect()->route('customers.index')->with('success', 'تم تسجيل الدفعة بنجاح.');
        } catch (\Exception $e) {
            DB::rollBack();
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage())->withInput();
        }
    }
}