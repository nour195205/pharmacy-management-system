@extends('layouts.naa')

@section('title', 'مرتجعات المشتريات')

@section('content')
<div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>مرتجعات المشتريات</h1>
    </div>

    @if (session('success'))
        <div class="alert alert-success">
            {{ session('success') }}
        </div>
    @endif
    @if (session('error'))
        <div class="alert alert-danger">
            {{ session('error') }}
        </div>
    @endif

    <div class="card shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead class="table-dark">
                        <tr>
                            <th>رقم المرتجع</th>
                            <th>رقم الفاتورة الأصلية</th>
                            <th>المورد</th>
                            <th>تاريخ المرتجع</th>
                            <th class="text-end">الإجمالي المسترجع</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($returns as $return)
                            <tr>
                                <td>#{{ $return->id }}</td>
                                <td>
                                    <a href="{{ route('purchase-invoices.show', $return->purchase_invoice_id) }}">
                                        #{{ $return->purchase_invoice_id }}
                                    </a>
                                </td>
                                <td>{{ $return->purchaseInvoice->supplier->name }}</td>
                                <td>{{ \Carbon\Carbon::parse($return->return_date)->format('Y-m-d') }}</td>
                                <td class="text-end">{{ number_format($return->total_amount, 2) }} جنيه</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="text-center py-4">لا توجد مرتجعات مشتريات حتى الآن.</td>
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