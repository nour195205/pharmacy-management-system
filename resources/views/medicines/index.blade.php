@extends('layouts.naa')

@section('content')
<div class="container">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="mb-0">💊 قائمة الأدوية</h1>
        <a href="{{ route('medicines.create') }}" class="btn btn-primary">إضافة دواء جديد</a>
    </div>

    {{-- شريط البحث --}}
    <div class="mb-3">
        <input type="text" id="page-search-input" class="form-control" placeholder="ابحث في الأدوية...">
    </div>

    @if (session('success'))
        <div class="alert alert-success">
            {{ session('success') }}
        </div>
    @endif

    <table id="data-table" class="table table-bordered table-striped"> {{-- أضفنا ID هنا --}}
        <thead class="table-dark">
            <tr>
                <th>#</th>
                <th>الاسم التجاري</th>
                <th>الوصف</th>
                <th>الفئة</th>
                <th>السعر</th>
                
                <th>إجراءات</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($medicines as $medicine)
                <tr>
                    <td>{{ $medicine->id }}</td>
                    <td>{{ $medicine->name }}</td>
                    <td>{{ $medicine->description }}</td>
                    <td>{{ $medicine->category }}</td>
                    <td>{{ $medicine->price }} ج.م</td>
                    
                    <td>
                        <a href="{{ route('medicines.show', $medicine->id) }}" class="btn btn-info btn-sm">عرض</a>
                        <a href="{{ route('medicines.edit', $medicine->id) }}" class="btn btn-warning btn-sm">تعديل</a>
                        <form action="{{ route('medicines.destroy', $medicine->id) }}" method="POST"
                            style="display: inline-block;" onsubmit="return confirm('هل أنت متأكد من الحذف؟');">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-danger btn-sm">حذف</button>
                        </form>
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="10" class="text-center">لا توجد أدوية متاحة حالياً.</td>
                </tr>
            @endforelse
        </tbody>
    </table>
</div>
@endsection