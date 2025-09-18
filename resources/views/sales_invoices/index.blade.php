@extends('layouts.naa')
@section('title', 'فواتير المبيعات')
@section('content')
<div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4"><h1>فواتير المبيعات</h1><a href="{{ route('sales-invoices.create') }}" class="btn btn-primary">إضافة فاتورة جديدة</a></div>
    <div class="card shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped table-hover">
                        <thead class="table-dark">
                            <tr>
                                <th>رقم الفاتورة</th>
                                <th>الفرع</th>
                                <th>التاريخ</th>
                                <th>الحالة</th>
                                <th>تم بواسطه</th>
                                <th class="text-end">الإجمالي</th>
                                <th>إجراءات</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse ($invoices as $invoice)
                                <tr>
                                    <td>#{{ $invoice->id }}</td>
                                    <td>{{ $invoice->branch->name }}</td>
                                    <td>{{ \Carbon\Carbon::parse($invoice->date)->format('Y-m-d') }}</td>
                                    <td><span class="badge bg-success">{{ $invoice->status }}</span></td>
                                    <td>{{ $invoice->creator->name }}</td>
                                    <td class="text-end">{{ number_format($invoice->total, 2) }} جنيه</td>
                                    <td>
                                        <a href="{{ route('sales-invoices.show', $invoice->id) }}" class="btn btn-sm btn-info">عرض</a>
                                        <a href="{{ route('sales-invoices.receipt', $invoice->id) }}" class="btn btn-sm btn-light" target="_blank">وصل</a>
                                        <a href="{{ route('sales-invoices.edit', $invoice->id) }}" class="btn btn-sm btn-warning">تعديل</a>
                                        <a href="{{ route('sales-returns.create', ['invoice_id' => $invoice->id]) }}" class="btn btn-sm btn-dark">إرجاع</a>
                                        <form action="{{ route('sales-invoices.destroy', $invoice->id) }}" method="POST" class="d-inline" onsubmit="return confirm('هل أنت متأكد من حذف هذه الفاتورة؟ سيتم إرجاع الكميات المباعة للمخزون.')">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-sm btn-danger">حذف</button>
                                        </form>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="7" class="text-center py-4">لا توجد فواتير مبيعات حتى الآن.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
            </div>
        </div>
        @if($invoices->hasPages())<div class="card-footer">{{ $invoices->links() }}</div>@endif
    </div>
</div>
@endsection