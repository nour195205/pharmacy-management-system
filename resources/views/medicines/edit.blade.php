@extends('layouts.naa')

@section('content')
<div class="container">
    <h2 class="mb-4">➕ تعديل دواء</h2>

    <form action="{{ route('medicines.update' , [$medicine]) }}" method="POST">
        @csrf
        @method('PUT')

        <div class="mb-3">
            <label class="form-label">اسم الدواء</label>
            <input type="text" name="name" class="form-control" value="{{ $medicine->name }}" required>
        </div>

        <div class="mb-3">
            <label class="form-label">التصنيف</label>
            <input type="text" name="category" class="form-control" value="{{ $medicine->category }}">
        </div>

        <div class="mb-3">
            <label class="form-label">الوصف</label>
            <textarea name="description" class="form-control" rows="3" value="{{ $medicine->description }}"></textarea>
        </div>

        <div class="mb-3">
            <label class="form-label">الباركود</label>
            <input type="text" name="barcode" class="form-control" value="{{ $medicine->barcode }}">
        </div>

        <div class="mb-3">
            <label class="form-label">الوحدة</label>
            <select name="unit" class="form-select" value="{{ $medicine->unit }}" required>
                <option value="شريط">شريط</option>
                <option value="علبه">علبة</option>
                <option value="زجاجه">زجاجة</option>
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">السعر (ج.م)</label>
            <input type="number" name="price" class="form-control" value="{{ $medicine->price }}" required>
        </div>

        <div class="mb-3">
            <label class="form-label">حد إعادة الطلب</label>
            <input type="text" name="reorder_level" class="form-control" value="{{ $medicine->reorder_level }}">
        </div>

        <div class="mb-3">
            <label class="form-label">الحالة</label>
            <select name="is_active" class="form-select" value="{{ $medicine->is_active }}">
                <option value="1">متاح</option>
                <option value="0">غير متاح</option>
            </select>
        </div>

        <button type="submit" class="btn btn-success">💾 حفظ</button>
        <a href="{{ route('medicines.index') }}" class="btn btn-secondary">⬅️ رجوع</a>
    </form>
</div>
@endsection
