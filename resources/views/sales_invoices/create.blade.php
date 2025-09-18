@extends('layouts.naa')

@section('title', 'إنشاء فاتورة مبيعات')

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
        <div class="card-header bg-success text-white">
            <h1 class="card-title h4 mb-0">فاتورة مبيعات جديدة</h1>
        </div>
        <div class="card-body">
            <form action="{{ route('sales-invoices.store') }}" method="POST">
                @csrf
                {{-- تفاصيل الفاتورة الأساسية --}}
                {{-- تفاصيل الفاتورة الأساسية --}}
                {{-- تفاصيل الفاتورة الأساسية --}}
                <div class="row mb-4">
                    <div class="col-md-3">
                        <label for="customer_id" class="form-label fw-bold">العميل</label>
                        <select name="customer_id" id="customer_id" class="form-select customer-select">
                            <option value="">-- بيع نقدي مباشر --</option>
                            @foreach ($customers as $customer)
                                <option value="{{ $customer->id }}">{{ $customer->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="branch_id" class="form-label fw-bold">الفرع</label>
                        <select name="branch_id" id="branch_id" class="form-select" required>
                            @foreach ($branches as $branch)
                                <option value="{{ $branch->id }}">{{ $branch->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label for="date" class="form-label fw-bold">التاريخ</label>
                        <input type="date" name="date" id="date" class="form-control" value="{{ old('date', now()->format('Y-m-d')) }}" required>
                    </div>
                    <div class="col-md-2">
                        <label for="payment_method" class="form-label fw-bold">طريقة الدفع</label>
                        <select name="payment_method" id="payment_method" class="form-select" required>
                            <option>نقدا</option>
                            <option>بطاقة</option>
                            <option>أخرى</option>
                        </select>
                    </div>
                    {{-- ====== هذا هو الحقل الناقص ====== --}}
                    <div class="col-md-2">
                        <label for="status" class="form-label fw-bold">الحالة</label>
                        <select name="status" id="status" class="form-select" required>
                            <option>مدفوع</option>
                            <option>معلق</option>
                            <option>ملغى</option>
                        </select>
                    </div>
                    {{-- =================================== --}}
                     <div class="col-md-12 mt-3">
                        <label for="note" class="form-label fw-bold">ملاحظات (اختياري)</label>
                        <input type="text" name="note" id="note" class="form-control" value="{{ old('note') }}">
                    </div>
                </div>

                <h3 class="mt-5 border-bottom pb-2">بنود الفاتورة</h3>
                <div id="invoice-items-container">
                    {{-- الصفوف الديناميكية ستضاف هنا --}}
                </div>

                <button type="button" id="add-item-btn" class="btn btn-dark mt-3">+ إضافة دواء يدويًا</button>

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
    // --- تهيئة العناصر الأساسية ---
    const itemsContainer = $('#invoice-items-container');
    const addItemBtn = $('#add-item-btn');
    const totalAmountSpan = $('#total-amount');
    let itemIndex = 0;
    
    // تخزين بيانات التشغيلات في متغير JavaScript لسهولة البحث
    const availableBatchesData = [
        @foreach ($availableBatches as $batch)
        {
            id: "{{ $batch->id }}",
            text: "{{ $batch->medicine->name }} (متوفر: {{ rtrim(rtrim(number_format($batch->quantity, 2), '0'), '.') }}) - [{{ $batch->branch->name }}] - (انتهاء: {{ \Carbon\Carbon::parse($batch->expiry_date)->format('Y-m') }})",
            price: "{{ $batch->selling_price }}",
            quantity: "{{ $batch->quantity }}",
            barcode: "{{ $batch->medicine->barcode }}" // أهم حقل للاسكانر
        },
        @endforeach
    ];

    // --- تفعيل Select2 على قائمة العملاء ---
    $('.customer-select').select2({
        placeholder: '-- بيع نقدي أو اختر عميل --',
        language: "ar",
        allowClear: true
    });

    // --- دالة لتفعيل Select2 على قوائم الأدوية ---
    function initializeSelect2(element) {
        element.select2({
            placeholder: '-- اختر من المخزون المتاح --',
            language: "ar",
            data: availableBatchesData
        });
    }

    // --- دالة لتحديث الإجمالي ---
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

    // --- دالة إضافة سطر جديد للفاتورة ---
    function addNewItemRow(batchData = null) {
        const itemHtml = `
            <div class="row item-row gx-2 gy-2 align-items-center mb-3 p-3 border rounded bg-light">
                <div class="col-lg-5"><label class="form-label">اختر الدواء</label><select name="items[${itemIndex}][batch_id]" class="form-select batch-select" required><option></option></select></div>
                <div class="col-lg-2 col-md-4"><label class="form-label">السعر</label><div class="input-group"><span class="input-group-text">جنيه</span><span class="form-control bg-white price-span">0.00</span></div></div>
                <div class="col-lg-2 col-md-4"><label class="form-label">الكمية المطلوبة</label><input type="number" name="items[${itemIndex}][quantity]" class="form-control quantity-input" min="0.1" step="0.1" required></div>
                <div class="col-lg-2 col-md-4"><label class="form-label">الإجمالي الجزئي</label><div class="input-group"><span class="input-group-text">جنيه</span><span class="form-control bg-white subtotal-span">0.00</span></div></div>
                <div class="col-lg-1 d-flex align-items-end"><button type="button" class="btn btn-danger w-100 remove-item-btn">حذف</button></div>
            </div>
        `;
        const newItem = $(itemHtml);
        itemsContainer.append(newItem);
        const selectElement = newItem.find('.batch-select');
        initializeSelect2(selectElement);

        // إذا تم تمرير بيانات (من الاسكانر)، قم بتحديدها
        if (batchData) {
            var option = new Option(batchData.text, batchData.id, true, true);
            selectElement.append(option).trigger('change');
            
            newItem.find('.price-span').text(parseFloat(batchData.price).toFixed(2));
            const quantityInput = newItem.find('.quantity-input');
            quantityInput.attr('max', batchData.quantity);
            quantityInput.attr('placeholder', `الحد الأقصى: ${batchData.quantity}`);
            quantityInput.val(1);
        }

        itemIndex++;
        updateTotalAmount();
        return newItem;
    }

    // --- زر الإضافة اليدوي ---
    addItemBtn.on('click', function() {
        addNewItemRow();
    });

    // --- منطق التعامل مع التغييرات في الصفوف ---
    itemsContainer.on('change', '.batch-select', function() {
        const selectedData = $(this).select2('data')[0];
        const row = $(this).closest('.item-row');
        if (selectedData && selectedData.id) {
            row.find('.price-span').text(parseFloat(selectedData.price).toFixed(2));
            const quantityInput = row.find('.quantity-input');
            quantityInput.attr('max', selectedData.quantity);
            quantityInput.attr('placeholder', `الحد الأقصى: ${selectedData.quantity}`);
        }
        updateTotalAmount();
    });

    itemsContainer.on('input', '.quantity-input', function() { updateTotalAmount(); });
    itemsContainer.on('click', '.remove-item-btn', function() {
        $(this).closest('.item-row').remove();
        updateTotalAmount();
    });

    // ===================================================
    // ===========   منطق الاسكانر التلقائي   ============
    // ===================================================
    let barcode = '';
    let lastKeyTime = new Date();

    $(document).on('keydown', function(e) {
        if ($(e.target).is('input, textarea, select')) {
            return;
        }

        const currentTime = new Date();
        if (currentTime - lastKeyTime > 100) {
            barcode = '';
        }

        if (e.key === 'Enter') {
            e.preventDefault();
            if (barcode.length > 3) {
                processBarcode(barcode);
            }
            barcode = '';
        } else {
            if (e.key.length === 1) {
                barcode += e.key;
            }
        }
        lastKeyTime = currentTime;
    });

    function processBarcode(scannedBarcode) {
        const batchData = availableBatchesData.find(batch => batch.barcode === scannedBarcode);
        
        if (!batchData) {
            alert('باركود غير موجود في المخزون!');
            return;
        }

        let existingRow = null;
        $('.item-row').each(function() {
            const row = $(this);
            if (row.find('.batch-select').val() === batchData.id) {
                existingRow = row;
                return false;
            }
        });

        if (existingRow) {
            const quantityInput = existingRow.find('.quantity-input');
            let currentQuantity = parseFloat(quantityInput.val()) || 0;
            const maxQuantity = parseFloat(quantityInput.attr('max'));
            
            if (currentQuantity < maxQuantity) {
                quantityInput.val(currentQuantity + 1);
            } else {
                alert('لقد وصلت للكمية القصوى المتاحة لهذه التشغيلة!');
            }
        } else {
            if (batchData.quantity > 0) {
                addNewItemRow(batchData);
            } else {
                alert('هذا الدواء نفد من المخزون!');
            }
        }
        updateTotalAmount();
    }
});
</script>
@endpush