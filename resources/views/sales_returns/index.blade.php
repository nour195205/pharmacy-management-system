@extends('layouts.naa')

@section('title', 'مرتجعات المبيعات')

@section('content')
<div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>مرتجعات المبيعات</h1>
        {{-- سنقوم بتفعيل هذا الزر لاحقاً إذا احتجناه --}}
        {{-- <a href="{{ route('sales-returns.create') }}" class="btn btn-primary">إضافة مرتجع جديد</a> --}}
    </div>

    <div class="card shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead class="table-dark">
                        <tr>
                            <th>رقم المرتجع</th>
                            <th>رقم الفاتورة الأصلية</th>
                            <th>تاريخ المرتجع</th>
                            <th>تم بواسطه</th>
                            <th class="text-end">الإجمالي المسترجع</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($returns as $return)
                            <tr>
                                <td>#{{ $return->id }}</td>
                                <td>
                                    <a href="{{ route('sales-invoices.show', $return->sales_invoice_id) }}">
                                        #{{ $return->sales_invoice_id }}
                                    </a>
                                </td>
                                <td>{{ \Carbon\Carbon::parse($return->date)->format('Y-m-d') }}</td>
                                <td>{{ $return->creator->name }}</td>
                                <td class="text-end">{{ number_format($return->total, 2) }} جنيه</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="text-center py-4">لا توجد مرتجعات مبيعات حتى الآن.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
        @if($returns->hasPages())
            <div class="card-footer">
                {{ $returns->links() }}
            </div>
        @endif
    </div>
</div>
@endsection