@extends('layouts.naa')

@section('title', 'قائمة الموردين')

@section('content')
    <div class="container mt-4">

        {{-- العنوان + زر إضافة --}}
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="mb-0">قائمة الموردين</h1>
            <!-- 1 -->
            <a href="{{ route('suppliers.create') }}" class="btn btn-primary">
                إضافة مورد جديد
            </a>
        </div>

        {{-- جدول الموردين --}}
        <div class="table-responsive">
            <table class="table table-bordered table-striped">
                <thead class="table-primary">
                    <tr>
                        <th>#</th>
                        <th>الاسم</th>
                        <th>معلومات الاتصال</th>
                        <th>العنوان</th>
                        <th>الهاتف</th>
                        <th>البريد الإلكتروني</th>
                        <th>الرصيد</th>
                        <th>الإجراءات</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($suppliers as $supplier)
                        <tr>
                            <td>{{ $supplier->id }}</td>
                            <td>{{ $supplier->name }}</td>
                            <td>{{ $supplier->contact_info ?? '-' }}</td>
                            <td>{{ $supplier->address ?? '-' }}</td>
                            <td>{{ $supplier->phone ?? '-' }}</td>
                            <td>{{ $supplier->email ?? '-' }}</td>
                            <td>{{ $supplier->balance }}</td>
                            <td class="d-flex gap-2">
                                <!-- 2 -->
                                {{-- زر التعديل --}}
                                <a href="{{ route('suppliers.edit', $supplier->id) }}" class="btn btn-sm btn-warning">تعديل</a>

                                {{-- زر الحذف --}}
                                <form action="{{ route('suppliers.destroy', $supplier->id) }}" method="POST"
                                    onsubmit="return confirm('هل أنت متأكد من الحذف؟');">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="btn btn-sm btn-danger">حذف</button>
                                </form>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

    </div>
@endsection