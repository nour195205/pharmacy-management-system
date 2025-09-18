@extends('layouts.naa')

@section('title', 'إنشاء فاتورة مبيعات')

{{-- تعديل بسيط على الـ CSS الخاص بـ Select2 ليتوافق مع Bootstrap --}}
@push('styles')
<style>
    .select2-container--default .select2-selection--single {
        height: 38px;
        border: 1px solid #ced4da;
    }
    .select2-container--default .select2-selection--single .select2-selection__rendered {
        line-height: 36px;
    }
    .select2-container--default .select2-selection--single .select2-selection__arrow {
        height: 36px;
    }
</style>
@endpush


@section('content')
<div class="container mt-5">
    <div class="card shadow-sm">
        <div class="card-header bg-success text-white">
            <h1 class="card-title h4 mb-0">فاتورة مبيعات جديدة</h1>
        </div>
        <div class="card-body">
            <form action="{{ route('sales-invoices.store') }}" method="POST">
                @csrf
                {{-- ... (باقي الفورم كما هو) ... --}}
                <div class="row mb-4">
                    <div class="col-md-3"><label for="branch_id" class="form-label fw-bold">الفرع</label><select name="branch_id" id="branch_id" class="form-select" required>@foreach ($branches as $branch)<option value="{{ $branch->id }}">{{ $branch->name }}</option>@endforeach</select></div>
                    <div class="col-md-3"><label for="date" class="form-label fw-bold">التاريخ</label><input type="date" name="date" id="date" class="form-control" value="{{ now()->format('Y-m-d') }}" required></div>
                    <div class="col-md-3"><label for="payment_method" class="form-label fw-bold">طريقة الدفع</label><select name="payment_method" id="payment_method" class="form-select"><option>نقدا</option><option>بطاقة</option><option>أخرى</option></select></div>
                    <div class="col-md-3"><label for="status" class="form-label fw-bold">الحالة</label><select name="status" id="status" class="form-select"><option>مدفوع</option><option>معلق</option><option>ملغى</option></select></div>
                    <div class="col-md-12 mt-3"><label for="note" class="form-label fw-bold">ملاحظات (اختياري)</label><input type="text" name="note" id="note" class="form-control" value="{{ old('note') }}"></div>
                </div>

                <h3 class="mt-5 border-bottom pb-2">بنود الفاتورة</h3>
                <div id="invoice-items-container">
                    {{-- الصفوف الديناميكية ستضاف هنا --}}
                </div>

                <button type="button" id="add-item-btn" class="btn btn-dark mt-3">+ إضافة دواء</button>

                <div class="mt-5 d-flex justify-content-end align-items-center">
                    <h4 class="me-4">الإجمالي: <span id="total-amount" class="fw-bold">0.00</span> جنيه</h4>
                    <button type="submit" class="btn btn-success btn-lg">حفظ الفاتورة</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
$(document).ready(function() {
    const itemsContainer = $('#invoice-items-container');
    const addItemBtn = $('#add-item-btn');
    const totalAmountSpan = $('#total-amount');
    let itemIndex = 0;

    function initializeSelect2(element) {
        element.select2({
            placeholder: '-- اختر من المخزون المتاح --',
            language: "ar"
        });
    }

    function updateTotalAmount() {
        let total = 0;
        $('.item-row').each(function() {
            const row = $(this);
            const quantity = parseFloat(row.find('.quantity-input').val()) || 0;
            const price = parseFloat(row.find('.price-span').text()) || 0;
            const subtotal = quantity * price;
            row.find('.subtotal-span').text(subtotal.toFixed(2));
            total += subtotal;
        });
        totalAmountSpan.text(total.toFixed(2));
    }

    addItemBtn.on('click', function() {
        const itemHtml = `
            <div class="row item-row gx-2 gy-2 align-items-center mb-3 p-3 border rounded bg-light">
                <div class="col-lg-5">
                    <label class="form-label">اختر الدواء</label>
                    <select name="items[${itemIndex}][batch_id]" class="form-select batch-select" required>
                        <option></option> {{-- Placeholder for Select2 --}}
                        @foreach ($availableBatches as $batch)
                            <option value="{{ $batch->id }}" data-price="{{ $batch->selling_price }}" data-quantity="{{ $batch->quantity }}">
                                {{ $batch->medicine->name }} (متوفر: {{ rtrim(rtrim(number_format($batch->quantity, 2), '0'), '.') }}) - [{{ $batch->branch->name }}] - (انتهاء: {{ \Carbon\Carbon::parse($batch->expiry_date)->format('Y-m') }})
                            </option>
                        @endforeach
                    </select>
                </div>
                <div class="col-lg-2 col-md-4">
                    <label class="form-label">السعر</label>
                    <div class="input-group">
                         <span class="input-group-text">جنيه</span>
                         <span class="form-control bg-white price-span">0.00</span>
                    </div>
                </div>
                <div class="col-lg-2 col-md-4">
                    <label class="form-label">الكمية المطلوبة</label>
                    <input type="number" name="items[${itemIndex}][quantity]" class="form-control quantity-input" min="0.1" step="0.1" required>
                </div>
                <div class="col-lg-2 col-md-4">
                     <label class="form-label">الإجمالي الجزئي</label>
                     <div class="input-group">
                         <span class="input-group-text">جنيه</span>
                         <span class="form-control bg-white subtotal-span">0.00</span>
                    </div>
                </div>
                <div class="col-lg-1 d-flex align-items-end">
                    <button type="button" class="btn btn-danger w-100 remove-item-btn">حذف</button>
                </div>
            </div>
        `;
        const newItem = $(itemHtml);
        itemsContainer.append(newItem);
        initializeSelect2(newItem.find('.batch-select')); // تفعيل Select2 على العنصر الجديد
        itemIndex++;
    });

    itemsContainer.on('change', '.batch-select', function() {
        const selectedOption = $(this).find('option:selected');
        const row = $(this).closest('.item-row');
        if (selectedOption.val()) {
            const price = selectedOption.data('price');
            const maxQuantity = selectedOption.data('quantity');
            row.find('.price-span').text(parseFloat(price).toFixed(2));
            const quantityInput = row.find('.quantity-input');
            quantityInput.attr('max', maxQuantity);
            quantityInput.attr('placeholder', `الحد الأقصى: ${maxQuantity}`);
        }
        updateTotalAmount();
    });

    itemsContainer.on('input', '.quantity-input', function() {
        updateTotalAmount();
    });

    itemsContainer.on('click', '.remove-item-btn', function() {
        $(this).closest('.item-row').remove();
        updateTotalAmount();
    });
});
</script>
@endpush