@extends('layouts.naa')

@section('title', 'تفاصيل مرتجع المبيعات')

@section('content')
<div class="container mt-5">
    <div class="card shadow-sm">
        <div class="card-header bg-secondary text-white d-flex justify-content-between align-items-center">
            <h1 class="card-title h4 mb-0">تفاصيل مرتجع رقم: #{{ $salesReturn->id }}</h1>
            <div>
                <a href="{{ route('sales-returns.index') }}" class="btn btn-outline-light btn-sm">
                    <i class="fas fa-arrow-right"></i> الرجوع للقائمة
                </a>
            </div>
        </div>
        <div class="card-body">
            {{-- تفاصيل المرتجع الأساسية --}}
            <div class="row mb-4">
                <div class="col-md-6">
                    <h5>معلومات المرتجع:</h5>
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item px-0"><strong>مرتبط بفاتورة المبيعات رقم:</strong> 
                            <a href="{{ route('sales-invoices.show', $salesReturn->sales_invoice_id) }}">
                                #{{ $salesReturn->sales_invoice_id }}
                            </a>
                        </li>
                        <li class="list-group-item px-0"><strong>تاريخ المرتجع:</strong> {{ \Carbon\Carbon::parse($salesReturn->date)->format('Y-m-d') }}</li>
                        <li class="list-group-item px-0"><strong>سبب الإرجاع:</strong> {{ $salesReturn->reason ?? 'لم يتم تحديد سبب' }}</li>
                    </ul>
                </div>
                <div class="col-md-6">
                    <h5>معلومات إضافية:</h5>
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item px-0"><strong>تم تسجيله بواسطة:</strong> {{ $salesReturn->creator->name }}</li>
                        <li class="list-group-item px-0"><strong>تاريخ التسجيل:</strong> {{ $salesReturn->created_at->format('Y-m-d H:i A') }}</li>
                    </ul>
                </div>
            </div>

            {{-- بنود المرتجع --}}
            <h3 class="mt-4 border-top pt-3">الأدوية المرتجعة</h3>
            <div class="table-responsive">
                <table class="table table-bordered table-striped table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>الدواء</th>
                            <th>رقم التشغيلة</th>
                            <th>الكمية المرتجعة</th>
                            <th>سعر البيع (للوحدة)</th>
                            <th class="text-end">الإجمالي المسترجع</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($salesReturn->items as $item)
                            <tr>
                                <td>{{ $item->batch->medicine->name }}</td>
                                <td>{{ $item->batch->batch_number }}</td>
                                <td>{{ rtrim(rtrim(number_format($item->quantity, 2), '0'), '.') }}</td>
                                <td>{{ number_format($item->selling_price, 2) }} جنيه</td>
                                <td class="text-end">{{ number_format($item->total, 2) }} جنيه</td>
                            </tr>
                        @endforeach
                    </tbody>
                    <tfoot class="table-group-divider">
                        <tr>
                            <td colspan="4" class="text-end fw-bold h5">الإجمالي النهائي للمرتجع</td>
                            <td class="text-end fw-bold h5 bg-light">{{ number_format($salesReturn->total, 2) }} جنيه</td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection

{{-- لإضافة أيقونة الرجوع، يمكنك إضافة Font Awesome في ملف naa.blade.php --}}
@push('styles')
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
@endpush