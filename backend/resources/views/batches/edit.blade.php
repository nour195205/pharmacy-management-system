@extends('layouts.naa')

@section('content')
<div class="container">
    <h2 class="mb-4">✏️ تعديل بيانات التشغيلة رقم: {{ $batch->id }}</h2>

    {{-- ======== قسم عرض أخطاء التحقق من الصحة ======== --}}
    @if ($errors->any())
        <div class="alert alert-danger">
            <strong>عذراً!</strong> حدثت بعض الأخطاء في البيانات المدخلة.<br><br>
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif
    {{-- =============================================== --}}


    <form action="{{ route('batches.update', $batch->id) }}" method="POST">
        @csrf
        @method('PUT')

        <div class="row">
            <div class="col-md-6 mb-3">
                <label for="medicine_id" class="form-label">الدواء</label>
                <select name="medicine_id" id="medicine_id" class="form-control" required>
                    @foreach ($medicines as $medicine)
                        <option value="{{ $medicine->id }}" @selected(old('medicine_id', $batch->medicine_id) == $medicine->id)>
                            {{ $medicine->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="col-md-6 mb-3">
                <label for="branch_id" class="form-label">الفرع</label>
                <select name="branch_id" id="branch_id" class="form-control" required>
                    @foreach ($branches as $branch)
                        <option value="{{ $branch->id }}" @selected(old('branch_id', $batch->branch_id) == $branch->id)>
                            {{ $branch->name }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>
        
        <div class="mb-3">
            <label for="batch_number" class="form-label">رقم التشغيلة</label>
            <input type="text" name="batch_number" id="batch_number" class="form-control" value="{{ old('batch_number', $batch->batch_number) }}" required>
        </div>

        <div class="row">
            <div class="col-md-6 mb-3">
                <label for="manufacture_date" class="form-label">تاريخ الإنتاج</label>
                {{-- استخدام Carbon لتحويل التاريخ إلى الصيغة الصحيحة Y-m-d --}}
                <input type="date" name="manufacture_date" id="manufacture_date" class="form-control" value="{{ old('manufacture_date', \Carbon\Carbon::parse($batch->manufacture_date)->format('Y-m-d')) }}" required>
            </div>
            <div class="col-md-6 mb-3">
                <label for="expiry_date" class="form-label">تاريخ الانتهاء</label>
                <input type="date" name="expiry_date" id="expiry_date" class="form-control" value="{{ old('expiry_date', \Carbon\Carbon::parse($batch->expiry_date)->format('Y-m-d')) }}" required>
            </div>
        </div>

        <div class="row">
             <div class="col-md-4 mb-3">
                <label for="quantity" class="form-label">الكمية</label>
                <input type="number" name="quantity" id="quantity" class="form-control" value="{{ old('quantity', $batch->quantity) }}" required min="0" step="1">
            </div>
            <div class="col-md-4 mb-3">
                <label for="purchase_price" class="form-label">سعر الشراء</label>
                <input type="number" name="purchase_price" id="purchase_price" class="form-control" value="{{ old('purchase_price', $batch->purchase_price) }}" required min="0" step="0.01">
            </div>
            <div class="col-md-4 mb-3">
                <label for="selling_price" class="form-label">سعر البيع</label>
                <input type="number" name="selling_price" id="selling_price" class="form-control" value="{{ old('selling_price', $batch->selling_price) }}" required min="0" step="0.01">
            </div>
        </div>

        <div class="mt-3">
            <button type="submit" class="btn btn-success">💾 تحديث التشغيلة</button>
            <a href="{{ route('batches.index') }}" class="btn btn-secondary">إلغاء</a>
        </div>
    </form>
</div>
@endsection