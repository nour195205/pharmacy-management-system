@extends('layouts.naa')

@section('title', 'إدارة العملاء')

@section('content')
<div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>العملاء</h1>
        <a href="{{ route('customers.create') }}" class="btn btn-primary">إضافة عميل جديد</a>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead class="table-dark">
                        <tr>
                            <th>#</th>
                            <th>اسم العميل</th>
                            <th>الهاتف</th>
                            <th>العنوان</th>
                            <th class="text-end">الرصيد الحالي (مدين)</th>
                            <th>إجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($customers as $customer)
                            <tr>
                                <td>{{ $customer->id }}</td>
                                <td>{{ $customer->name }}</td>
                                <td>{{ $customer->phone ?? 'غير مسجل' }}</td>
                                <td>{{ $customer->address ?? 'غير مسجل' }}</td>
                                <td class="text-end fw-bold {{ optional($customer->account)->balance > 0 ? 'text-danger' : 'text-success' }}">
                                    {{ number_format(optional($customer->account)->balance ?? 0, 2) }} جنيه
                                </td>
                                <td>
                                    {{-- <a href="#" class="btn btn-sm btn-info">كشف حساب</a> --}}
                                    <a href="{{ route('customers.edit', $customer->id) }}" class="btn btn-sm btn-warning">تعديل</a>
                                    <form action="{{ route('customers.destroy', $customer->id) }}" method="POST" class="d-inline" onsubmit="return confirm('هل أنت متأكد من حذف هذا العميل؟')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="btn btn-sm btn-danger">حذف</button>
                                    </form>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="6" class="text-center py-4">لا يوجد عملاء مسجلين حتى الآن.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
        @if($customers->hasPages())
            <div class="card-footer">
                {{ $customers->links() }}
            </div>
        @endif
    </div>
</div>
@endsection