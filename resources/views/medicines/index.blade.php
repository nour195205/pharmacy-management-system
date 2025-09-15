@extends('layouts.naa')

@section('content')
<div class="container">
    <h2 class="mb-4">قائمة الأدوية</h2>

    <a href="{{ route('medicines.create') }}" class="btn btn-primary mb-3">➕ إضافة دواء جديد</a>

    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th>#</th>
                <th>الاسم</th>
                <th>التصنيف</th>
                <th>الباركود</th>
                <th>الوحدة</th>
                <th>السعر</th>
                <th>حد إعادة الطلب</th>
                <th>الحالة</th>
                <th>التحكم</th>
            </tr>
        </thead>
        <tbody>
            @forelse($medicines as $medicine)
                <tr>
                    <td>{{ $medicine->id }}</td>
                    <td>{{ $medicine->name }}</td>
                    <td>{{ $medicine->category }}</td>
                    <td>{{ $medicine->barcode }}</td>
                    <td>{{ $medicine->unit }}</td>
                    <td>{{ $medicine->price }} ج.م</td>
                    <td>{{ $medicine->reorder_level }}</td>
                    <td>
                        @if($medicine->is_active)
                            <span class="badge bg-success">متاح</span>
                        @else
                            <span class="badge bg-danger">غير متاح</span>
                        @endif
                    </td>
                    <td>
                        <a href="{{ route('medicines.edit', $medicine->id) }}" class="btn btn-warning btn-sm">✏️ تعديل</a>
                        <form action="{{ route('medicines.destroy', $medicine->id) }}" method="POST" style="display:inline-block;">
                            @csrf
                            @method('DELETE')
                            <button class="btn btn-danger btn-sm" onclick="return confirm('هل أنت متأكد من الحذف؟')">🗑️ حذف</button>
                        </form>
                        <a href="{{ route('medicines.show', $medicine->id) }}" class="btn btn-warning btn-sm">التفاصيل</a>
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="9" class="text-center">لا توجد أدوية مسجلة</td>
                </tr>
            @endforelse
        </tbody>
    </table>
</div>
@endsection
