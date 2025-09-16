@extends('layouts.naa')

@section('content')
<div class="container">
    <h1>تفاصيل الدُفعة</h1>

    <div class="card">
        <div class="card-body">
            <p><strong>اسم الدواء:</strong> {{ $batch->medicine->name }}</p>
            <p><strong>رقم الدُفعة:</strong> {{ $batch->batch_number }}</p>
            <p><strong>تاريخ التصنيع:</strong> {{ $batch->manufacture_date }}</p>
            <p><strong>تاريخ الانتهاء:</strong> {{ $batch->expiry_date }}</p>
            <p><strong>الكمية:</strong> {{ $batch->quantity }}</p>
            <p><strong>سعر الشراء:</strong> {{ $batch->purchase_price }}</p>
            <p><strong>سعر البيع:</strong> {{ $batch->selling_price }}</p>
            <p><strong>الفرع:</strong> {{ $batch->branch->name }}</p>
        </div>
    </div>

    <a href="{{ route('batches.index') }}" class="btn btn-secondary mt-3">رجوع</a>
    <a href="{{ route('batches.edit', $batch->id) }}" class="btn btn-primary mt-3">تعديل</a>
</div>
@endsection
