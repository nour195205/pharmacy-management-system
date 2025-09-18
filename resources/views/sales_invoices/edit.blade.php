@extends('layouts.naa')
@section('title', 'تعديل فاتورة مبيعات')
@push('styles')
<style>
    .select2-container--default .select2-selection--single { height: 38px; border: 1px solid #ced4da; }
    .select2-container--default .select2-selection--single .select2-selection__rendered { line-height: 36px; }
    .select2-container--default .select2-selection--single .select2-selection__arrow { height: 36px; }
</style>
@endpush
@section('content')
<div class="container mt-5">
    <div class="card shadow-sm">
        <div class="card-header bg-warning text-dark"><h1 class="card-title h4 mb-0">تعديل فاتورة مبيعات رقم #{{ $salesInvoice->id }}</h1></div>
        <div class="card-body">
            <form action="{{ route('sales-invoices.update', $salesInvoice->id) }}" method="POST">
                @csrf
                @method('PUT')
                <div class="row mb-4">
                    <div class="col-md-3"><label for="customer_id" class="form-label fw-bold">العميل</label><select name="customer_id" class="form-select customer-select"><option value="">-- بيع نقدي مباشر --</option>@foreach ($customers as $customer)<option value="{{ $customer->id }}" @selected(old('customer_id', $salesInvoice->customer_id) == $customer->id)>{{ $customer->name }}</option>@endforeach</select></div>
                    <div class="col-md-3"><label for="branch_id" class="form-label fw-bold">الفرع</label><select name="branch_id" id="branch_id" class="form-select" required>@foreach ($branches as $branch)<option value="{{ $branch->id }}" @selected(old('branch_id', $salesInvoice->branch_id) == $branch->id)>{{ $branch->name }}</option>@endforeach</select></div>
                    <div class="col-md-2"><label for="date" class="form-label fw-bold">التاريخ</label><input type="date" name="date" id="date" class="form-control" value="{{ old('date', \Carbon\Carbon::parse($salesInvoice->date)->format('Y-m-d')) }}" required></div>
                    <div class="col-md-2"><label for="payment_method" class="form-label fw-bold">طريقة الدفع</label><select name="payment_method" id="payment_method" class="form-select"><option @selected(old('payment_method', $salesInvoice->payment_method) == 'نقدا')>نقدا</option><option @selected(old('payment_method', $salesInvoice->payment_method) == 'بطاقة')>بطاقة</option><option @selected(old('payment_method', $salesInvoice->payment_method) == 'أخرى')>أخرى</option></select></div>
                    <div class="col-md-2"><label for="status" class="form-label fw-bold">الحالة</label><select name="status" id="status" class="form-select"><option @selected(old('status', $salesInvoice->status) == 'مدفوع')>مدفوع</option><option @selected(old('status', $salesInvoice->status) == 'معلق')>معلق</option><option @selected(old('status', $salesInvoice->status) == 'ملغى')>ملغى</option></select></div>
                    <div class="col-md-12 mt-3"><label for="note" class="form-label fw-bold">ملاحظات (اختياري)</label><input type="text" name="note" id="note" class="form-control" value="{{ old('note', $salesInvoice->note) }}"></div>
                </div>
                <h3 class="mt-5 border-bottom pb-2">بنود الفاتورة</h3>
                <div id="invoice-items-container">
                     @foreach($salesInvoice->items as $index => $item)
                        <div class="row item-row gx-2 gy-2 align-items-center mb-3 p-3 border rounded bg-light">
                            <div class="col-lg-5"><label class="form-label">اختر الدواء</label><select name="items[{{ $index }}][batch_id]" class="form-select batch-select" required><option value="{{ $item->batch_id }}" selected>{{ $item->batch->medicine->name }} (متوفر: {{ $item->batch->quantity + $item->qty }})</option></select></div>
                            <div class="col-lg-2 col-md-4"><label class="form-label">السعر</label><div class="input-group"><span class="input-group-text">جنيه</span><span class="form-control bg-white price-span">{{ number_format($item->price, 2) }}</span></div></div>
                            <div class="col-lg-2 col-md-4"><label class="form-label">الكمية المطلوبة</label><input type="number" name="items[{{ $index }}][quantity]" class="form-control quantity-input" value="{{ $item->qty }}" min="0.1" step="0.1" required></div>
                            <div class="col-lg-2 col-md-4"><label class="form-label">الإجمالي الجزئي</label><div class="input-group"><span class="input-group-text">جنيه</span><span class="form-control bg-white subtotal-span">{{ number_format($item->total, 2) }}</span></div></div>
                            <div class="col-lg-1 d-flex align-items-end"><button type="button" class="btn btn-danger w-100 remove-item-btn">حذف</button></div>
                        </div>
                    @endforeach
                </div>
                <button type="button" id="add-item-btn" class="btn btn-dark mt-3">+ إضافة دواء</button>
                <div class="mt-5 d-flex justify-content-end align-items-center"><h4 class="me-4">الإجمالي: <span id="total-amount" class="fw-bold">{{ number_format($salesInvoice->total, 2) }}</span> جنيه</h4><button type="submit" class="btn btn-warning btn-lg">حفظ التعديلات</button></div>
            </form>
        </div>
    </div>
</div>
@endsection


@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function () {
    const itemsContainer = document.getElementById('invoice-items-container');
    const addItemBtn = document.getElementById('add-item-btn');
    const batchesDatalist = document.getElementById('batches-list');
    const totalAmountSpan = document.getElementById('total-amount');
    let itemIndex = {{ $salesInvoice->items->count() }}; // يبدأ العد من عدد البنود الحالية

    // دالة لتحديث الإجمالي
    function updateTotalAmount() {
        let total = 0;
        document.querySelectorAll('.item-row').forEach(row => {
            const quantity = parseFloat(row.querySelector('.quantity-input').value) || 0;
            const price = parseFloat(row.querySelector('.price-span').textContent) || 0;
            const subtotal = quantity * price;
            row.querySelector('.subtotal-span').textContent = subtotal.toFixed(2);
            total += subtotal;
        });
        totalAmountSpan.textContent = total.toFixed(2);
    }

    // عند الضغط على زر "إضافة دواء"
    addItemBtn.addEventListener('click', function () {
        const itemHtml = `
            <div class="row item-row gx-2 gy-2 align-items-center mb-3 p-3 border rounded bg-light">
                <div class="col-lg-5">
                    <label class="form-label">اختر الدواء</label>
                    <input list="batches-list" name="items[${itemIndex}][batch_id]" class="form-control batch-input" placeholder="ابدأ بكتابة اسم الدواء..." required>
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
        itemsContainer.insertAdjacentHTML('beforeend', itemHtml);
        itemIndex++;
    });

    // عند تغيير الدواء المختار أو الكمية (باستخدام 'input' لكليهما)
    itemsContainer.addEventListener('input', function(e) {
        if (e.target.classList.contains('batch-input')) {
            const selectedOption = Array.from(batchesDatalist.options).find(opt => opt.value === e.target.value);
            const row = e.target.closest('.item-row');
            if (selectedOption) {
                const price = selectedOption.getAttribute('data-price');
                const maxQuantity = selectedOption.getAttribute('data-quantity');
                row.querySelector('.price-span').textContent = parseFloat(price).toFixed(2);
                const quantityInput = row.querySelector('.quantity-input');
                quantityInput.max = maxQuantity;
                quantityInput.placeholder = `الحد الأقصى: ${maxQuantity}`;
            }
        }
        // تحديث الإجمالي دائمًا مع أي تغيير
        updateTotalAmount();
    });

    // عند الضغط على زر الحذف
    itemsContainer.addEventListener('click', function(e) {
        if (e.target.classList.contains('remove-item-btn')) {
            e.target.closest('.item-row').remove();
            updateTotalAmount();
        }
    });
});
</script>

@endpush