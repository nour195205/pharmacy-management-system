<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCustomerRequest;
use App\Http\Requests\UpdateCustomerRequest;
use App\Http\Resources\CustomerResource;
use App\Models\Customer;
use App\Services\CustomerService;
use App\Traits\ApiResponse;

class CustomerController extends Controller
{
    use ApiResponse;

    public function __construct(private CustomerService $customerService) {}

    public function index()
    {
        return $this->success(
            CustomerResource::collection($this->customerService->getAll()),
            'تم جلب العملاء بنجاح'
        );
    }

    public function store(StoreCustomerRequest $request)
    {
        $customer = $this->customerService->create($request->validated());
        return $this->created(new CustomerResource($customer->load('account')), 'تم إضافة العميل بنجاح');
    }

    public function show(Customer $customer)
    {
        return $this->success(new CustomerResource($customer->load('account')));
    }

    public function update(UpdateCustomerRequest $request, Customer $customer)
    {
        $customer = $this->customerService->update($customer, $request->validated());
        return $this->success(new CustomerResource($customer), 'تم تعديل بيانات العميل بنجاح');
    }

    public function destroy(Customer $customer)
    {
        $this->customerService->delete($customer);
        return $this->success(null, 'تم حذف العميل بنجاح');
    }
}
