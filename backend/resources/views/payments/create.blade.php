@extends('layouts.naa')
@section('title', 'تسجيل دفعة من عميل')
@section('content')
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow-sm">
                <div class="card-header bg-success text-white">
                    <h1 class="card-title h4 mb-0">تسجيل دفعة من العميل: {{ $customer->name }}</h1>
                </div>
                <div class="card-body">
                    <div class="alert alert-info">
                        الرصيد الحالي (مدين): <strong>{{ number_format($customer->account->balance, 2) }} جنيه</strong>
                    </div>
                    <form action="{{ route('customers.payments.store', $customer->id) }}" method="POST">
                        @csrf
                        <div class="mb-3">
                            <label for="amount" class="form-label fw-bold">المبلغ المدفوع</label>
                            <input type="number" name="amount" id="amount" class="form-control" value="{{ old('amount') }}" min="0.01" max="{{ $customer->account->balance }}" step="0.01" required>
                        </div>
                        <div class="mb-3">
                            <label for="date" class="form-label fw-bold">تاريخ الدفع</label>
                            <input type="date" name="date" id="date" class="form-control" value="{{ old('date', now()->format('Y-m-d')) }}" required>
                        </div>
                        <div class="mb-3">
                            <label for="notes" class="form-label fw-bold">ملاحظات (اختياري)</label>
                            <textarea name="notes" id="notes" class="form-control" rows="3">{{ old('notes') }}</textarea>
                        </div>
                        <div class="mt-4 text-end">
                            <a href="{{ route('customers.index') }}" class="btn btn-secondary">إلغاء</a>
                            <button type="submit" class="btn btn-success">حفظ الدفعة</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection