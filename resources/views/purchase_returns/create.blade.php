@extends('layouts.naa')

@section('title', 'إنشاء مرتجع مشتريات')

@section('content')
<div class="container mt-5">
    <div class="card shadow-sm">
        <div class="card-header bg-dark text-white">
            <h1 class="card-title h4 mb-0">إنشاء مرتجع جديد للفاتورة رقم #{{ $invoice->id }}</h1>
        </div>
        <div class="card-body">
            @if ($errors->any())
                <div class="alert alert-danger">
                    <ul class="mb-0">
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <form action="{{ route('purchase-returns.store') }}" method="POST">
                @csrf
                <input type="hidden" name="purchase_invoice_id" value="{{ $invoice->id }}">

                {{-- تفاصيل المرتجع الأساسية --}}
                <div class="row mb-4">
                    <div class="col-md-4">
                        <label for="date" class="form-label fw-bold">تاريخ المرتجع</label>
                        <input type="date" name="date" id="date" class="form-control" value="{{ old('date', now()->format('Y-m-d')) }}" required>
                    </div>
                    <div class="col-md-8">
                        <label for="reason" class="form-label fw-bold">السبب (اختياري)</label>
                        <input type="text" name="reason" id="reason" class="form-control" value="{{ old('reason') }}">
                    </div>
                </div>

                <h3 class="mt-4 border-top pt-3">حدد الكميات المراد إرجاعها:</h3>
                <div class="table-responsive">
                    <table class="table table-bordered">
                        <thead class="table-light">
                            <tr>
                                <th>الدواء</th>
                                <th>رقم التشغيلة</th>
                                <th>الكمية المشتراة</th>
                                <th>الكمية المتاحة للإرجاع</th>
                                <th style="width: 15%;">الكمية المرتجعة</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($invoice->items as $item)
                                @php
                                    $batch = $item->batch;
                                    $totalPurchased = $item->qty;
                                    $alreadyReturned = $returnedQuantities[$batch->id] ?? 0;
                                    $availableForReturn = $batch->quantity; // الكمية الحالية في المخزون من هذه الدفعة
                                @endphp
                                <tr>
                                    <td>{{ $batch->medicine->name }}</td>
                                    <td>{{ $batch->batch_number }}</td>
                                    <td>{{ $totalPurchased }}</td>
                                    <td><span class="badge bg-success">{{ $availableForReturn }}</span></td>
                                    <td>
                                        <input type="hidden" name="items[{{ $loop->index }}][batch_id]" value="{{ $batch->id }}">
                                        <input type="number" name="items[{{ $loop->index }}][quantity]" class="form-control" value="{{ old('items.'.$loop->index.'.quantity', 0) }}" min="0" max="{{ $availableForReturn }}">
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>

                <div class="mt-4 text-end">
                    <button type="submit" class="btn btn-danger btn-lg">تنفيذ الإرجاع</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection