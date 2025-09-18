@extends('layouts.naa')

@section('title', 'إنشاء مرتجع مبيعات')

@section('content')
<div class="container mt-5">
    <div class="card shadow-sm">
        <div class="card-header bg-danger text-white">
            <h1 class="card-title h4 mb-0">إنشاء مرتجع جديد للفاتورة رقم #{{ $invoice->id }}</h1>
        </div>
        <div class="card-body">
            <form action="{{ route('sales-returns.store') }}" method="POST">
                @csrf
                <input type="hidden" name="sales_invoice_id" value="{{ $invoice->id }}">

                {{-- تفاصيل المرتجع الأساسية --}}
                <div class="row mb-4">
                    <div class="col-md-4">
                        <label for="date" class="form-label fw-bold">تاريخ المرتجع</label>
                        <input type="date" name="date" id="date" class="form-control" value="{{ old('date', now()->format('Y-m-d')) }}" required>
                    </div>
                    <div class="col-md-8">
                        <label for="reason" class="form-label fw-bold">سبب الإرجاع (اختياري)</label>
                        <input type="text" name="reason" id="reason" class="form-control" value="{{ old('reason') }}">
                    </div>
                </div>

                <h3 class="mt-4 border-top pt-3">حدد الكميات المراد إرجاعها:</h3>
                <div class="table-responsive">
                    <table class="table table-bordered">
                        <thead class="table-light">
                            <tr>
                                <th>الدواء</th>
                                <th>الكمية المباعة</th>
                                <th style="width: 20%;">الكمية المرتجعة</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($invoice->items as $item)
                                <tr>
                                    <td>{{ $item->batch->medicine->name }}</td>
                                    <td>{{ rtrim(rtrim(number_format($item->qty, 2), '0'), '.') }}</td>
                                    <td>
                                        <input type="hidden" name="items[{{ $loop->index }}][sales_item_id]" value="{{ $item->id }}">
                                        <input type="number" name="items[{{ $loop->index }}][quantity]" class="form-control" value="{{ old('items.'.$loop->index.'.quantity', 0) }}" min="0" max="{{ $item->qty }}" step="0.1">
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