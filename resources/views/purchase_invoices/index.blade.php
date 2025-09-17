@extends('layouts.naa')

@section('title', 'فواتير المشتريات')

@section('content')
<div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>فواتير المشتريات</h1>
        <a href="{{ route('purchase-invoices.create') }}" class="btn btn-primary">إضافة فاتورة جديدة</a>
    </div>
    {{-- ========== ابدأ النسخ من هنا ========== --}}
            @if ($errors->any())
                <div class="alert alert-danger">
                    <ul class="mb-0">
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif
            {{-- ========== انتهي من النسخ هنا ========== --}}
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

    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead class="table-dark">
                        <tr>
                            <th>رقم الفاتورة</th>
                            <th>المورد</th>
                            <th>التاريخ</th>
                            <th>الإجمالي</th>
                            <th>إجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($invoices as $invoice)
                            <tr>
                                <td>{{ $invoice->id }}</td>
                                <td>{{ $invoice->supplier->name }}</td>
                                <td>{{ \Carbon\Carbon::parse($invoice->invoice_date)->format('Y-m-d') }}</td>
                                <td>{{ number_format($invoice->total_amount, 2) }} جنيه</td>
                                <td>
                                    <a href="{{ route('purchase-invoices.show', $invoice->id) }}" class="btn btn-sm btn-info">عرض</a>
                                    <a href="{{ route('purchase-invoices.edit', $invoice->id) }}" class="btn btn-sm btn-warning">تعديل</a>
                                    <a href="{{ route('purchase-invoices.print', $invoice->id) }}" class="btn btn-sm btn-secondary">طباعة</a>
                                    <form action="{{ route('purchase-invoices.destroy', $invoice->id) }}" method="POST" class="d-inline" onsubmit="return confirm('هل أنت متأكد من حذف هذه الفاتورة؟')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="btn btn-sm btn-danger">حذف</button>
                                    </form>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="text-center">لا توجد فواتير مشتريات حتى الآن.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
        <div class="card-footer">
            {{ $invoices->links() }}
        </div>
    </div>
</div>
@endsection