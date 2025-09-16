@extends('layouts.naa')

@section('content')
<div class="container">
    <h2 class="mb-4">📦 قائمة التشغيلات</h2>

    <div class="mb-3">
        <a href="{{ route('batches.create') }}" class="btn btn-primary">➕ إضافة تشغيلة جديدة</a>
    </div>

    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif

    <table class="table table-bordered table-striped">
        <thead class="table-dark">
            <tr>
                <th>#</th>
                <th>اسم الدواء</th>
                <th>رقم التشغيلة</th>
                <th>تاريخ الإنتاج</th>
                <th>تاريخ الانتهاء</th>
                <th>الكمية</th>
                <th>سعر الشراء</th>
                <th>سعر البيع</th>
                <th>الفرع</th>
                <th>إجراءات</th>
            </tr>
        </thead>
        <tbody>
            @forelse($batches as $batch)
                <tr>
                    <td>{{ $batch->id }}</td>
                    <td>{{ $batch->medicine->name ?? '—' }}</td>
                    <td>{{ $batch->batch_number }}</td>
                    <td>{{ $batch->manufacture_date }}</td>
                    <td>{{ $batch->expiry_date }}</td>
                    <td>{{ $batch->quantity }}</td>
                    <td>{{ $batch->purchase_price }} ج.م</td>
                    <td>{{ $batch->selling_price }} ج.م</td>
                    <td>{{ $batch->branch->name ?? '—' }}</td>
                    <td>
                        <a href="{{ route('batches.show', $batch->id) }}" class="btn btn-info btn-sm">👁️ عرض</a>
                        <a href="{{ route('batches.edit', $batch->id) }}" class="btn btn-warning btn-sm">✏️ تعديل</a>
                        <form action="{{ route('batches.destroy', $batch->id) }}" method="POST" class="d-inline">
                            @csrf
                            @method('DELETE')
                            <button onclick="return confirm('هل أنت متأكد من الحذف؟')" class="btn btn-danger btn-sm">🗑️ حذف</button>
                        </form>
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="10" class="text-center">⚠️ لا توجد تشغيلات مسجلة</td>
                </tr>
            @endforelse
        </tbody>
    </table>
</div>
@endsection
