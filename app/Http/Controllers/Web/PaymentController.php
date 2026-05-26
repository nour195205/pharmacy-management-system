<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\StorePaymentRequest;
use App\Models\Customer;
use App\Services\PaymentService;

class PaymentController extends Controller
{
    public function __construct(private PaymentService $paymentService) {}

    public function create(Customer $customer)
    {
        return view('payments.create', compact('customer'));
    }

    public function store(StorePaymentRequest $request, Customer $customer)
    {
        try {
            $data = array_merge($request->validated(), ['user_id' => auth()->id()]);
            $this->paymentService->createPayment($customer, $data);
            return redirect()->route('customers.index')->with('success', 'تم تسجيل الدفعة بنجاح.');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage())->withInput();
        }
    }
}
