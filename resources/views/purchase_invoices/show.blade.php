@extends('layouts.naa')

@section('title', 'تفاصيل فاتورة المشتريات')

@section('content')
<div class="container mt-5">
    <div class="card">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h1 class="card-title mb-0">تفاصيل فاتورة رقم: {{ $purchaseInvoice->id }}</h1>
            <div>
                <a href="{{ route('purchase-invoices.print', $purchaseInvoice->id) }}" class="btn btn-secondary" target="_blank">طباعة</a>
                <a href="{{ route('purchase-invoices.index') }}" class="btn btn-primary">الرجوع للقائمة</a>
            </div>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-6">
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item"><strong>الفرع:</strong> {{ $purchaseInvoice->branch->name }}</li>
                        <li class="list-group-item"><strong>المورد:</strong> {{ $purchaseInvoice->supplier->name }}</li>
                        <li class="list-group-item"><strong>تاريخ الفاتورة:</strong> {{ \Carbon\Carbon::parse($purchaseInvoice->invoice_date)->format('Y-m-d') }}</li>
                    </ul>
                </div>
                <div class="col-md-6">
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item"><strong>تم إنشاؤها بواسطة:</strong> {{ $purchaseInvoice->user->name }}</li>
                        <li class="list-group-item"><strong>إجمالي الفاتورة:</strong> <span class="fw-bold fs-5">{{ number_format($purchaseInvoice->total_amount, 2) }} جنيه</span></li>
                    </ul>
                </div>
            </div>

            <h3 class="mt-5">بنود الفاتورة</h3>
            <div class="table-responsive">
                <table class="table table-bordered table-striped">
                    <thead class="table-light">
                        <tr>
                            <th>الدواء</th>
                            <th>رقم التشغيلة</th>
                            <th>الكمية</th>
                            <th>سعر الشراء</th>
                            <th>سعر البيع</th>
                            <th>تاريخ الإنتاج</th>
                            <th>تاريخ الانتهاء</th>
                            <th>الإجمالي الجزئي</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($purchaseInvoice->items as $item)
                            <tr>
                                <td>{{ $item->batch->medicine->name }}</td>
                                <td>{{ $item->batch->batch_number }}</td>
                                <td>{{ $item->qty }}</td>
                                <td>{{ number_format($item->price, 2) }} جنيه</td>
                                <td>{{ number_format($item->batch->selling_price, 2) }} جنيه</td>
                                <td>{{ \Carbon\Carbon::parse($item->batch->manufacture_date)->format('Y-m-d') }}</td>
                                <td>{{ \Carbon\Carbon::parse($item->batch->expiry_date)->format('Y-m-d') }}</td>
                                <td>{{ number_format($item->total, 2) }} جنيه</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection