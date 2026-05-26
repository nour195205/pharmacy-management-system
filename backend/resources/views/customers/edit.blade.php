@extends('layouts.naa')

@section('title', 'تعديل بيانات العميل')

@section('content')
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow-sm">
                <div class="card-header bg-warning text-dark">
                    <h1 class="card-title h4 mb-0">تعديل بيانات العميل: {{ $customer->name }}</h1>
                </div>
                <div class="card-body">
                    @if ($errors->any())
                        <div class="alert alert-danger">
                            <ul class="mb-0">
                                @foreach ($errors->all() as $error)
                                    <li>{{ $error }}</li>
                                @endforeach
                            </ul>
                        </div>
                    @endif

                    <form action="{{ route('customers.update', $customer->id) }}" method="POST">
                        @csrf
                        @method('PUT') {{--  لتحديد أن هذه عملية تحديث --}}
                        
                        <div class="mb-3">
                            <label for="name" class="form-label fw-bold">اسم العميل</label>
                            <input type="text" name="name" id="name" class="form-control" value="{{ old('name', $customer->name) }}" required>
                        </div>

                        <div class="mb-3">
                            <label for="phone" class="form-label fw-bold">رقم الهاتف (اختياري)</label>
                            <input type="text" name="phone" id="phone" class="form-control" value="{{ old('phone', $customer->phone) }}">
                        </div>

                        <div class="mb-3">
                            <label for="address" class="form-label fw-bold">العنوان (اختياري)</label>
                            <textarea name="address" id="address" class="form-control" rows="3">{{ old('address', $customer->address) }}</textarea>
                        </div>

                        <div class="mb-3">
                            <label for="credit_limit" class="form-label fw-bold">حد الائتمان (اختياري)</label>
                            <div class="input-group">
                                <input type="number" name="credit_limit" id="credit_limit" class="form-control" value="{{ old('credit_limit', $customer->credit_limit) }}" min="0" step="0.01">
                                <span class="input-group-text">جنيه</span>
                            </div>
                            <div class="form-text">
                                هذا هو أقصى مبلغ يمكن للعميل أن يكون مدينًا به. اتركه صفرًا إذا لم يكن هناك حد.
                            </div>
                        </div>

                        <div class="mt-4 text-end">
                            <a href="{{ route('customers.index') }}" class="btn btn-secondary">إلغاء</a>
                            <button type="submit" class="btn btn-warning">حفظ التعديلات</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection