@extends('layouts.naa')

@section('title', 'إضافة فاتورة مشتريات')

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
        <div class="card-header bg-primary text-white">
            <h1 class="card-title h4 mb-0">إضافة فاتورة مشتريات جديدة</h1>
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

            <form action="{{ route('purchase-invoices.store') }}" method="POST">
                @csrf
                {{-- تفاصيل الفاتورة الأساسية --}}
                <div class="row mb-4">
                    <div class="col-md-4">
                        <label for="branch_id" class="form-label fw-bold">الفرع</label>
                        <select name="branch_id" id="branch_id" class="form-select" required>
                            @foreach ($branches as $branch)
                                <option value="{{ $branch->id }}">{{ $branch->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label for="supplier_id" class="form-label fw-bold">المورد</label>
                        <select name="supplier_id" id="supplier_id" class="form-select" required>
                            @foreach ($suppliers as $supplier)
                                <option value="{{ $supplier->id }}">{{ $supplier->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label for="invoice_date" class="form-label fw-bold">تاريخ الفاتورة</label>
                        <input type="date" name="invoice_date" id="invoice_date" class="form-control" value="{{ now()->format('Y-m-d') }}" required>
                    </div>
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

                <div class="mt-5 text-end">
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
    let itemIndex = 0;
    
    // تخزين بيانات الأدوية في متغير JavaScript لسهولة البحث
    const medicinesData = [
        @foreach ($medicines as $medicine)
        {
            id: "{{ $medicine->id }}",
            text: "{{ $medicine->name }}",
            barcode: "{{ $medicine->barcode }}",
            selling_price: "{{ $medicine->price }}" // استخدام السعر من جدول الأدوية كسعر بيع افتراضي
        },
        @endforeach
    ];

    // --- تفعيل Select2 ---
    $('#medicine_search').select2({
        placeholder: 'ابحث بالاسم أو الباركود أو اختر من القائمة...',
        language: "ar",
        data: medicinesData,
        matcher: function(params, data) {
            if ($.trim(params.term) === '') { return null; }
            const term = params.term.toLowerCase();
            const text = data.text.toLowerCase();
            const barcode = data.barcode ? data.barcode.toLowerCase() : '';
            if (text.indexOf(term) > -1 || barcode.indexOf(term) > -1) {
                return data;
            }
            return null;
        }
    });

    // --- دالة لإضافة أو تحديث بند في الفاتورة ---
    function addOrUpdateItem(medicineData) {
        if (!medicineData) return;

        let existingRow = itemsContainer.find(`.item-row[data-medicine-id="${medicineData.id}"]`);

        if (existingRow.length > 0) {
            // إذا كان موجودًا، قم بزيادة الكمية
            const quantityInput = existingRow.find('.quantity-input');
            let currentQuantity = parseInt(quantityInput.val()) || 0;
            quantityInput.val(currentQuantity + 1);
        } else {
            // إذا لم يكن موجودًا، أضف سطرًا جديدًا
            const itemHtml = `
                <div class="row item-row gx-2 gy-2 align-items-center mb-3 p-3 border rounded bg-light" data-medicine-id="${medicineData.id}">
                    <div class="col-lg-3">
                        <label class="form-label">الدواء</label>
                        <input type="hidden" name="items[${itemIndex}][medicine_id]" value="${medicineData.id}">
                        <input type="text" class="form-control bg-white" value="${medicineData.text}" readonly>
                    </div>
                    <div class="col-lg-1 col-md-6"><label class="form-label">الكمية</label><input type="number" name="items[${itemIndex}][quantity]" class="form-control quantity-input" value="1" min="1" required></div>
                    <div class="col-lg-2 col-md-6"><label class="form-label">سعر الشراء</label><input type="number" step="0.01" name="items[${itemIndex}][purchase_price]" class="form-control" min="0" required></div>
                    <div class="col-lg-2 col-md-6"><label class="form-label">سعر البيع</label><input type="number" step="0.01" name="items[${itemIndex}][selling_price]" class="form-control" value="${parseFloat(medicineData.selling_price).toFixed(2)}" min="0" required></div>
                    <div class="col-lg-2 col-md-6"><label class="form-label">تاريخ الإنتاج</label><input type="date" name="items[${itemIndex}][manufacture_date]" class="form-control" required></div>
                    <div class="col-lg-2 col-md-6"><label class="form-label">تاريخ الانتهاء</label><input type="date" name="items[${itemIndex}][expiry_date]" class="form-control" required></div>
                    <div class="col-lg-auto d-flex align-items-end"><button type="button" class="btn btn-danger w-100 remove-item-btn">حذف</button></div>
                </div>
            `;
            itemsContainer.append(itemHtml);
            itemIndex++;
        }
    }

    // --- عند الاختيار اليدوي من مربع البحث ---
    $('#medicine_search').on('select2:select', function (e) {
        var data = e.params.data;
        addOrUpdateItem(data);
        $(this).val(null).trigger('change');
    });

    itemsContainer.on('click', '.remove-item-btn', function() {
        $(this).closest('.item-row').remove();
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
                const medicineData = medicinesData.find(med => med.barcode === barcode);
                if(medicineData){
                    addOrUpdateItem(medicineData);
                } else {
                    alert('باركود غير موجود في قائمة الأدوية الأساسية!');
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