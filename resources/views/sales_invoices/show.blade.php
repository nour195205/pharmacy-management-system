@extends('layouts.naa')

@section('title', 'تفاصيل فاتورة مبيعات')

@section('content')
<div class="container mt-5">
    <div class="card shadow-sm">
        <div class="card-header bg-info text-white d-flex justify-content-between align-items-center">
            <h1 class="card-title h4 mb-0">تفاصيل فاتورة مبيعات رقم: #{{ $salesInvoice->id }}</h1>
            <div>
                <a href="{{ route('sales-invoices.receipt', $salesInvoice->id) }}" class="btn btn-light btn-sm" target="_blank">طباعة وصل</a>
                {{-- <a href="#" class="btn btn-light btn-sm" target="_blank">طباعة</a> --}}
                <a href="{{ route('sales-invoices.index') }}" class="btn btn-outline-light btn-sm">الرجوع للقائمة</a>
            </div>
        </div>
        <div class="card-body">
            {{-- تفاصيل الفاتورة الأساسية --}}
            <div class="row mb-4">
                <div class="col-md-6">
                    <h5>معلومات الفاتورة:</h5>
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item px-0"><strong>الفرع:</strong> {{ $salesInvoice->branch->name }}</li>
                        <li class="list-group-item px-0"><strong>التاريخ:</strong> {{ \Carbon\Carbon::parse($salesInvoice->date)->format('Y-m-d') }}</li>
                        <li class="list-group-item px-0"><strong>الحالة:</strong> <span class="badge bg-success">{{ $salesInvoice->status }}</span></li>
                        <li class="list-group-item px-0"><strong>طريقة الدفع:</strong> {{ $salesInvoice->payment_method }}</li>
                    </ul>
                </div>
                <div class="col-md-6">
                    <h5>معلومات إضافية:</h5>
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item px-0"><strong>تم إنشاؤها بواسطة:</strong> {{ $salesInvoice->creator->name }}</li>
                        <li class="list-group-item px-0"><strong>ملاحظات:</strong> {{ $salesInvoice->note ?? 'لا يوجد' }}</li>
                    </ul>
                </div>
            </div>

            {{-- بنود الفاتورة --}}
            <h3 class="mt-4 border-top pt-3">بنود الفاتورة</h3>
            <div class="table-responsive">
                <table class="table table-bordered table-striped table-hover">
                    <thead class="table-info">
                        <tr>
                            <th>الدواء</th>
                            <th>رقم التشغيلة</th>
                            <th>الكمية</th>
                            <th>سعر البيع</th>
                            <th class="text-end">الإجمالي الجزئي</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($salesInvoice->items as $item)
                            <tr>
                                <td>{{ $item->batch->medicine->name }}</td>
                                <td>{{ $item->batch->batch_number }}</td>
                                <td>{{ $item->qty }}</td>
                                <td>{{ number_format($item->price, 2) }} جنيه</td>
                                <td class="text-end">{{ number_format($item->total, 2) }} جنيه</td>
                            </tr>
                        @endforeach
                    </tbody>
                    <tfoot class="table-group-divider">
                        <tr>
                            <td colspan="4" class="text-end fw-bold h5">الإجمالي النهائي للفاتورة</td>
                            <td class="text-end fw-bold h5 bg-light">{{ number_format($salesInvoice->total, 2) }} جنيه</td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection