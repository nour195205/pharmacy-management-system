@extends('layouts.naa')

@section('title', 'تعديل فاتورة مشتريات')

@section('content')
<div class="container mt-5">
    <div class="card">
        <div class="card-header">
            <h1 class="card-title">تعديل فاتورة مشتريات رقم: {{ $purchaseInvoice->id }}</h1>
        </div>
        <div class="card-body">
            @if ($errors->any())
                <div class="alert alert-danger">
                    <ul>
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <form action="{{ route('purchase-invoices.update', $purchaseInvoice->id) }}" method="POST">
                @csrf
                @method('PUT')
                {{-- تفاصيل الفاتورة الأساسية --}}
                <div class="row mb-4">
                    <div class="col-md-4">
                        <label for="branch_id" class="form-label">الفرع</label>
                        <select name="branch_id" id="branch_id" class="form-select" required>
                            @foreach ($branches as $branch)
                                <option value="{{ $branch->id }}" @selected($purchaseInvoice->branch_id == $branch->id)>
                                    {{ $branch->name }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label for="supplier_id" class="form-label">المورد</label>
                        <select name="supplier_id" id="supplier_id" class="form-select" required>
                            @foreach ($suppliers as $supplier)
                                <option value="{{ $supplier->id }}" @selected($purchaseInvoice->supplier_id == $supplier->id)>
                                    {{ $supplier->name }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label for="invoice_date" class="form-label">تاريخ الفاتورة</label>
                        <input type="date" name="invoice_date" id="invoice_date" class="form-control" value="{{ \Carbon\Carbon::parse($purchaseInvoice->invoice_date)->format('Y-m-d') }}" required>
                    </div>
                </div>

                <h3 class="mt-5">بنود الفاتورة</h3>
                <div id="invoice-items-container">
                    {{-- عرض البنود الحالية --}}
                    @foreach ($purchaseInvoice->items as $index => $item)
                        <div class="row item-row gx-3 gy-2 align-items-center mb-3 p-3 border rounded">
                            <div class="col-md-3">
                                <label class="form-label">الدواء</label>
                                <select name="items[{{ $index }}][medicine_id]" class="form-select" required>
                                    @foreach($medicines as $medicine)
                                        <option value="{{ $medicine->id }}" @selected($item->batch->medicine_id == $medicine->id)>{{ $medicine->name }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <div class="col-auto">
                                <label class="form-label">الكمية</label>
                                <input type="number" name="items[{{ $index }}][quantity]" class="form-control" value="{{ $item->qty }}" min="1" required>
                            </div>
                            <div class="col-auto">
                                <label class="form-label">سعر الشراء</label>
                                <input type="number" step="0.01" name="items[{{ $index }}][purchase_price]" class="form-control" value="{{ $item->price }}" min="0" required>
                            </div>
                            <div class="col-auto">
                                <label class="form-label">سعر البيع</label>
                                <input type="number" step="0.01" name="items[{{ $index }}][selling_price]" class="form-control" value="{{ $item->batch->selling_price }}" min="0" required>
                            </div>
                            <div class="col-auto">
                                <label class="form-label">تاريخ الإنتاج</label>
                                <input type="date" name="items[{{ $index }}][manufacture_date]" class="form-control" value="{{ \Carbon\Carbon::parse($item->batch->manufacture_date)->format('Y-m-d') }}" required>
                            </div>
                            <div class="col-auto">
                                <label class="form-label">تاريخ الانتهاء</label>
                                <input type="date" name="items[{{ $index }}][expiry_date]" class="form-control" value="{{ \Carbon\Carbon::parse($item->batch->expiry_date)->format('Y-m-d') }}" required>
                            </div>
                            <div class="col-auto d-flex align-items-end">
                                <button type="button" class="btn btn-danger w-100 remove-item-btn">حذف</button>
                            </div>
                        </div>
                    @endforeach
                </div>

                <button type="button" id="add-item-btn" class="btn btn-secondary mt-3">+ إضافة دواء</button>

                <div class="mt-5 text-end">
                    <button type="submit" class="btn btn-success btn-lg">حفظ التعديلات</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection

@push('scripts')
{{-- نفس الكود الخاص بصفحة الإنشاء مع تعديلات بسيطة --}}
<script>
document.addEventListener('DOMContentLoaded', function () {
    const itemsContainer = document.getElementById('invoice-items-container');
    let itemIndex = {{ $purchaseInvoice->items->count() }};

    document.getElementById('add-item-btn').addEventListener('click', function () {
        const itemHtml = `
            <div class="row item-row gx-3 gy-2 align-items-center mb-3 p-3 border rounded">
                <div class="col-md-3"><label class="form-label">الدواء</label><select name="items[${itemIndex}][medicine_id]" class="form-select" required><option value="">-- اختر دواء --</option>@foreach($medicines as $medicine)<option value="{{ $medicine->id }}">{{ $medicine->name }}</option>@endforeach</select></div>
                <div class="col-auto"><label class="form-label">الكمية</label><input type="number" name="items[${itemIndex}][quantity]" class="form-control" min="1" required></div>
                <div class="col-auto"><label class="form-label">سعر الشراء</label><input type="number" step="0.01" name="items[${itemIndex}][purchase_price]" class="form-control" min="0" required></div>
                <div class="col-auto"><label class="form-label">سعر البيع</label><input type="number" step="0.01" name="items[${itemIndex}][selling_price]" class="form-control" min="0" required></div>
                <div class="col-auto"><label class="form-label">تاريخ الإنتاج</label><input type="date" name="items[${itemIndex}][manufacture_date]" class="form-control" required></div>
                <div class="col-auto"><label class="form-label">تاريخ الانتهاء</label><input type="date" name="items[${itemIndex}][expiry_date]" class="form-control" required></div>
                <div class="col-auto d-flex align-items-end"><button type="button" class="btn btn-danger w-100 remove-item-btn">حذف</button></div>
            </div>
        `;
        itemsContainer.insertAdjacentHTML('beforeend', itemHtml);
        itemIndex++;
    });

    itemsContainer.addEventListener('click', function (e) {
        if (e.target && e.target.classList.contains('remove-item-btn')) {
            e.target.closest('.item-row').remove();
        }
    });
});
</script>
@endpush