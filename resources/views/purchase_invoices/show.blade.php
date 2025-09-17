@extends('layouts.naa')

@section('title', 'تفاصيل فاتورة المشتريات')

@section('content')
<div class="container mt-5">
    <div class="card shadow-sm">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
            <h1 class="card-title h4 mb-0">تفاصيل فاتورة مشتريات رقم: #{{ $purchaseInvoice->id }}</h1>
            <div>
                <a href="{{ route('purchase-invoices.print', $purchaseInvoice->id) }}" class="btn btn-light btn-sm" target="_blank">
                    <i class="fas fa-print"></i> طباعة
                </a>
                <a href="{{ route('purchase-invoices.index') }}" class="btn btn-outline-light btn-sm">
                    <i class="fas fa-arrow-right"></i> الرجوع للقائمة
                </a>
            </div>
        </div>
        <div class="card-body">
            {{-- تفاصيل الفاتورة الأساسية --}}
            <div class="row mb-4">
                <div class="col-md-6">
                    <h5>معلومات الفاتورة:</h5>
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item px-0"><strong>الفرع:</strong> {{ $purchaseInvoice->branch->name }}</li>
                        <li class="list-group-item px-0"><strong>تاريخ الفاتورة:</strong> {{ \Carbon\Carbon::parse($purchaseInvoice->invoice_date)->format('Y-m-d') }}</li>
                        <li class="list-group-item px-0"><strong>تم إنشاؤها بواسطة:</strong> {{ $purchaseInvoice->user->name }}</li>
                    </ul>
                </div>
                <div class="col-md-6">
                    <h5>معلومات المورد:</h5>
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item px-0"><strong>اسم المورد:</strong> {{ $purchaseInvoice->supplier->name }}</li>
                        <li class="list-group-item px-0"><strong>هاتف المورد:</strong> {{ $purchaseInvoice->supplier->phone }}</li>
                        <li class="list-group-item px-0"><strong>عنوان المورد:</strong> {{ $purchaseInvoice->supplier->address }}</li>
                    </ul>
                </div>
            </div>

            {{-- بنود الفاتورة --}}
            <h3 class="mt-4 border-top pt-3">بنود الفاتورة</h3>
            <div class="table-responsive">
                <table class="table table-bordered table-striped table-hover">
                    <thead class="table-primary">
                        <tr>
                            <th>الدواء</th>
                            <th>رقم التشغيلة</th>
                            <th>الكمية</th>
                            <th>سعر الشراء</th>
                            <th>سعر البيع</th>
                            <th>تاريخ الإنتاج</th>
                            <th>تاريخ الانتهاء</th>
                            <th class="text-end">الإجمالي الجزئي</th>
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
                                <td class="text-end">{{ number_format($item->total, 2) }} جنيه</td>
                            </tr>
                        @endforeach
                    </tbody>
                    <tfoot class="table-group-divider">
                        <tr>
                            <td colspan="7" class="text-end fw-bold h5">الإجمالي النهائي للفاتورة</td>
                            <td class="text-end fw-bold h5 bg-light">{{ number_format($purchaseInvoice->total_amount, 2) }} جنيه</td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection

{{-- لإضافة أيقونات الطباعة والرجوع، يمكنك إضافة Font Awesome في ملف naa.blade.php --}}
@push('styles')
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
@endpush