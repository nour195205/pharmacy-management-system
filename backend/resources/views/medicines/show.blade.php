@extends('layouts.naa')

@section('content')
<div class="container">
    <h2 class="mb-4">📦 تفاصيل الدواء</h2>
    <br>
    <div class="card">
        <div class="card-body">
            <h4 class="card-title">{{ $medicine->name }}</h4>
            <p><strong>التصنيف:</strong> 
            <br>
            {{ $medicine->category ?? '—' }}</p>
            <br>
            <p><strong>الوصف:</strong> <br>{{ $medicine->description ?? '—' }}</p><br>
            <p><strong>الباركود:</strong> <br>{{ $medicine->barcode ?? '—' }}</p><br>
            <p><strong>الوحدة:</strong><br> {{ $medicine->unit }}</p><br>
            <p><strong>السعر:</strong><br> {{ $medicine->price }} ج.م</p><br>
            <p><strong>حد إعادة الطلب:</strong> <br>{{ $medicine->reorder_level ?? '—' }}</p><br>
            <p><strong>الوصف:</strong> <br>{{ $medicine->description ?? '—' }}</p><br>
            <p>
                <strong>الحالة:</strong> <br>
                @if($medicine->is_active)
                    <span class="badge bg-success">متاح ✅</span>
                @else
                    <span class="badge bg-danger">غير متاح ❌</span>
                @endif
            </p><br>
            <p><strong>تاريخ الإضافة:</strong><br> {{ $medicine->created_at->format('Y-m-d') }}</p>
        </div>
    </div>

    <div class="mt-3">
        <a href="{{ route('medicines.index') }}" class="btn btn-secondary">⬅️ رجوع</a>
        <a href="{{ route('medicines.edit', $medicine->id) }}" class="btn btn-warning">✏️ تعديل</a>

        <form action="{{ route('medicines.destroy', $medicine->id) }}" method="POST" class="d-inline">
            @csrf
            @method('DELETE')
            <button class="btn btn-danger" onclick="return confirm('هل أنت متأكد من الحذف؟')">🗑️ حذف</button>
        </form>
    </div>
</div>
<br><br>
@endsection
