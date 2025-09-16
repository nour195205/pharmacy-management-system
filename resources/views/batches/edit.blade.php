@extends('layouts.naa')

@section('content')
<div class="container">
    <h2 class="mb-4">➕ تعديل تشغيلة</h2>

    <form action="{{ route('batches.store') }}" method="POST">
        @csrf

        <div class="mb-3">
            <label class="form-label">اسم الدواء</label>
            <select name="medicine_id" class="form-select" value="{{ $batch->medicine_id }}" required>
                <option value="">اختر الدواء</option>
                @foreach($medicines as $medicine)
                    <option value="{{ $medicine->id }}">{{ $medicine->name }}</option>
                @endforeach
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">رقم التشغيلة</label>
            <input type="number" name="batch_number" class="form-control" value="{{ $batch->batch_number }}" required>
        </div>

        <div class="mb-3">
            <label class="form-label">تاريخ الإنتاج</label>
            <input type="date" name="manufacture_date" class="form-control" value="{{ $batch->manufacture_date }}" required>
        </div>

        <div class="mb-3">
            <label class="form-label">تاريخ الانتهاء</label>
            <input type="date" name="expiry_date" class="form-control" value="{{ $batch->expiry_date }}" required>
        </div>

        <div class="mb-3">
            <label class="form-label">الكمية</label>
            <input type="number" name="quantity" class="form-control" value="{{ $batch->quantity }}" required min="1">
        </div>

        <div class="mb-3">
            <label class="form-label">سعر الشراء (ج.م)</label>
            <input type="number" name="purchase_price" class="form-control" value="{{ $batch->purchase_price }}" required min="0">
        </div>

        <div class="mb-3">
            <label class="form-label">سعر البيع (ج.م)</label>
            <input type="number" name="selling_price" class="form-control" value="{{ $batch->selling_price }}" required min="0">
        </div>

        <div class="mb-3">
            <label class="form-label">الفرع</label>
            <select name="branch_id" class="form-select" value="{{ $batch->branch_id }}" required>
                <option value="">اختر الفرع</option>
                @foreach($branches as $branch)
                    <option value="{{ $branch->id }}">{{ $branch->name }}</option>
                @endforeach
            </select>
        </div>

        <button type="submit" class="btn btn-success">💾 حفظ</button>
        <a href="{{ route('batches.index') }}" class="btn btn-secondary">⬅️ رجوع</a>
    </form>
</div>
@endsection
