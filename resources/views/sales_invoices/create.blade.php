@extends('layouts.naa')

@section('title', 'إنشاء فاتورة مبيعات')

@push('styles')
{{-- أكواد CSS خاصة بمكتبة Select2 لجعلها متوافقة مع Bootstrap --}}
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
                {{-- تفاصيل الفاتورة الأساسية --}}
                <div class="row mb-4">
                    <div class="col-md-3">
                        <label for="customer_id" class="form-label fw-bold">العميل</label>
                        <select name="customer_id" class="form-select customer-select">
                            <option value="">-- بيع نقدي مباشر --</option>
                            @foreach ($customers as $customer)
                                <option value="{{ $customer->id }}">{{ $customer->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-3"><label for="branch_id" class="form-label fw-bold">الفرع</label><select name="branch_id" id="branch_id" class="form-select" required>@foreach ($branches as $branch)<option value="{{ $branch->id }}">{{ $branch->name }}</option>@endforeach</select></div>
                    <div class="col-md-2"><label for="date" class="form-label fw-bold">التاريخ</label><input type="date" name="date" id="date" class="form-control" value="{{ old('date', now()->format('Y-m-d')) }}" required></div>
                    <div class="col-md-2"><label for="payment_method" class="form-label fw-bold">طريقة الدفع</label><select name="payment_method" id="payment_method" class="form-select" required><option>نقدا</option><option>بطاقة</option><option>أخرى</option></select></div>
                    <div class="col-md-2"><label for="status" class="form-label fw-bold">الحالة</label><select name="status" id="status" class="form-select" required><option>مدفوع</option><option>معلق</option><option>ملغى</option></select></div>
                    <div class="col-md-12 mt-3"><label for="note" class="form-label fw-bold">ملاحظات (اختياري)</label><input type="text" name="note" id="note" class="form-control" value="{{ old('note') }}"></div>
                </div>

                {{-- منطقة البحث وإضافة الأدوية --}}
                <div class="row align-items-end p-3 mb-3 border rounded bg-light">
                    <div class="col-md-12">
                        <label for="medicine_search" class="form-label fw-bold">ابحث عن دواء لإضافته للفاتورة (بالاسم أو الباركود)</label>
                        <select id="medicine_search" class="form-select">
                            <option></option> {{-- Placeholder for Select2 --}}
                        </select>
                    </div>
                </div>

                <h3 class="mt-4 border-bottom pb-2">بنود الفاتورة</h3>
                <div id="invoice-items-container">
                    {{-- الصفوف الديناميكية ستضاف هنا --}}
                </div>

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
            barcode: "{{ $batch->medicine->barcode }}"
        },
        @endforeach
    ];

    // --- تفعيل Select2 ---
    $('.customer-select').select2({
        placeholder: '-- بيع نقدي أو اختر عميل --',
        language: "ar",
        allowClear: true
    });

    // ====== ابدأ التعديل هنا (إضافة دالة البحث المخصصة) ======
    $('#medicine_search').select2({
        placeholder: 'ابحث بالاسم أو الباركود أو اختر من القائمة...',
        language: "ar",
        data: availableBatchesData,
        matcher: function(params, data) {
            // إذا كان مربع البحث فارغًا، لا تظهر أي نتائج
            if ($.trim(params.term) === '') {
                return null;
            }

            // تحويل كل شيء إلى حروف صغيرة لسهولة المقارنة
            const term = params.term.toLowerCase();
            const text = data.text.toLowerCase();
            const barcode = data.barcode ? data.barcode.toLowerCase() : '';

            // تحقق إذا كان الاسم أو الباركود يحتوي على كلمة البحث
            if (text.indexOf(term) > -1 || barcode.indexOf(term) > -1) {
                return data;
            }

            // إذا لم يتم العثور على تطابق، لا تظهر النتيجة
            return null;
        }
    });
    // ====== انتهي من التعديل هنا ======


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
    
    // --- دالة لإضافة أو تحديث بند في الفاتورة ---
    function addOrUpdateItem(batchData) {
        if (!batchData) return;

        let existingRow = itemsContainer.find(`.item-row[data-batch-id="${batchData.id}"]`);

        if (existingRow.length > 0) {
            const quantityInput = existingRow.find('.quantity-input');
            let currentQuantity = parseFloat(quantityInput.val()) || 0;
            const maxQuantity = parseFloat(quantityInput.attr('max'));
            
            if (currentQuantity < maxQuantity) {
                quantityInput.val(currentQuantity + 1);
            } else {
                alert('لقد وصلت للكمية القصوى المتاحة لهذه التشغيلة!');
            }
        } else {
            if (parseFloat(batchData.quantity) > 0) {
                 const itemHtml = `
                    <div class="row item-row gx-2 gy-2 align-items-center mb-3 p-3 border rounded bg-light" data-batch-id="${batchData.id}">
                        <div class="col-lg-5">
                            <input type="hidden" name="items[${itemIndex}][batch_id]" value="${batchData.id}">
                            <input type="text" class="form-control bg-white" value="${batchData.text}" readonly>
                        </div>
                        <div class="col-lg-2 col-md-4"><div class="input-group"><span class="input-group-text">جنيه</span><span class="form-control bg-white price-span">${parseFloat(batchData.price).toFixed(2)}</span></div></div>
                        <div class="col-lg-2 col-md-4"><input type="number" name="items[${itemIndex}][quantity]" class="form-control quantity-input" value="1" min="0.1" max="${batchData.quantity}" step="0.1" required></div>
                        <div class="col-lg-2 col-md-4"><div class="input-group"><span class="input-group-text">جنيه</span><span class="form-control bg-white subtotal-span">${parseFloat(batchData.price).toFixed(2)}</span></div></div>
                        <div class="col-lg-1 d-flex align-items-end"><button type="button" class="btn btn-danger w-100 remove-item-btn">حذف</button></div>
                    </div>
                `;
                itemsContainer.append(itemHtml);
                itemIndex++;
            } else {
                alert('هذا الدواء نفد من المخزون!');
            }
        }
        updateTotalAmount();
    }

    // --- عند الاختيار اليدوي من مربع البحث ---
    $('#medicine_search').on('select2:select', function (e) {
        var data = e.params.data;
        addOrUpdateItem(data);
        $(this).val(null).trigger('change');
    });

    itemsContainer.on('input', '.quantity-input', function() { updateTotalAmount(); });
    itemsContainer.on('click', '.remove-item-btn', function() {
        $(this).closest('.item-row').remove();
        updateTotalAmount();
    });

    // --- منطق الاسكانر التلقائي ---
    let barcode = '';
    let lastKeyTime = new Date();

    $(document).on('keydown', function(e) {
        if ($(e.target).is('input, textarea') || $(e.target).closest('.select2-container').length) {
            return;
        }

        const currentTime = new Date();
        if (currentTime - lastKeyTime > 100) { barcode = ''; }

        if (e.key === 'Enter') {
            e.preventDefault();
            if (barcode.length > 3) {
                const batchData = availableBatchesData.find(batch => batch.barcode === barcode && parseFloat(batch.quantity) > 0);
                if(batchData){
                    addOrUpdateItem(batchData);
                } else {
                    alert('باركود غير موجود أو نفدت كميته من المخزون!');
                }
            }
            barcode = '';
        } else {
            if (e.key.length === 1) { barcode += e.key; }
        }
        lastKeyTime = currentTime;
    });
});
</script>
@endpush