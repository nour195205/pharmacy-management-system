@extends('layouts.naa')

@section('content')
<div class="container">
    <h2 class="mb-4">➕ إضافة دواء جديد</h2>

    <form action="{{ route('medicines.store') }}" method="POST">
        @csrf

        <div class="mb-3">
            <label class="form-label">اسم الدواء</label>
            <input type="text" name="name" class="form-control" required>
        </div>

        <div class="mb-3">
            <label class="form-label">التصنيف</label>
            <input type="text" name="category" class="form-control">
        </div>

        <div class="mb-3">
            <label class="form-label">الوصف</label>
            <textarea name="description" class="form-control" rows="3"></textarea>
        </div>

        <div class="mb-3">
            <label class="form-label">الباركود</label>
            <input type="text" name="barcode" class="form-control">
        </div>

        <div class="mb-3">
            <label class="form-label">الوحدة</label>
            <select name="unit" class="form-select" required>
                <option value="شريط">شريط</option>
                <option value="علبه">علبة</option>
                <option value="زجاجه">زجاجة</option>
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">السعر (ج.م)</label>
            <input type="number" name="price" class="form-control" required>
        </div>

        <div class="mb-3">
            <label class="form-label">حد إعادة الطلب</label>
            <input type="text" name="reorder_level" class="form-control">
        </div>

        <div class="mb-3">
            <label class="form-label">الحالة</label>
            <select name="is_active" class="form-select">
                <option value="1">متاح</option>
                <option value="0">غير متاح</option>
            </select>
        </div>

        <button type="submit" class="btn btn-success">💾 حفظ</button>
        <a href="{{ route('medicines.index') }}" class="btn btn-secondary">⬅️ رجوع</a>
    </form>
</div>
@endsection
