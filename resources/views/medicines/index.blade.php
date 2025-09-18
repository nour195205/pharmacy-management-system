@extends('layouts.naa')

@section('title', 'قائمة الأدوية')

@section('content')
<div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="mb-0">قائمة الأدوية</h1>
        <a href="{{ route('medicines.create') }}" class="btn btn-primary">➕ إضافة دواء جديد</a>
    </div>

    {{-- ====== ابدأ الإضافة هنا (حقل البحث) ====== --}}
    <div class="mb-3">
        <input type="text" id="searchInput" class="form-control" placeholder="ابحث بالاسم أو الباركود...">
    </div>
    {{-- ======================================= --}}

    <div class="card shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-bordered table-striped table-hover">
                    <thead class="table-dark">
                        <tr>
                            <th>#</th>
                            <th>الاسم</th>
                            <th>التصنيف</th>
                            <th>الباركود</th>
                            <th>الوحدة</th>
                            <th>السعر</th>
                            <th>حد إعادة الطلب</th>
                            <th>الحالة</th>
                            <th>التحكم</th>
                        </tr>
                    </thead>
                    {{-- أضفنا id للـ tbody ليسهل الوصول إليه --}}
                    <tbody id="medicinesTable">
                        @forelse($medicines as $medicine)
                            <tr>
                                <td>{{ $medicine->id }}</td>
                                <td>{{ $medicine->name }}</td>
                                <td>{{ $medicine->category }}</td>
                                <td>{{ $medicine->barcode }}</td>
                                <td>{{ $medicine->unit }}</td>
                                <td>{{ $medicine->price }} ج.م</td>
                                <td>{{ $medicine->reorder_level }}</td>
                                <td>
                                    @if($medicine->is_active)
                                        <span class="badge bg-success">متاح</span>
                                    @else
                                        <span class="badge bg-danger">غير متاح</span>
                                    @endif
                                </td>
                                <td>
                                    <a href="{{ route('medicines.edit', $medicine->id) }}" class="btn btn-warning btn-sm">✏️ تعديل</a>
                                    <form action="{{ route('medicines.destroy', $medicine->id) }}" method="POST" class="d-inline" onsubmit="return confirm('هل أنت متأكد من الحذف؟')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="btn btn-danger btn-sm">🗑️ حذف</button>
                                    </form>
                                    {{-- <a href="{{ route('medicines.show', $medicine->id) }}" class="btn btn-info btn-sm">التفاصيل</a> --}}
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="9" class="text-center">لا توجد أدوية مسجلة</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection

{{-- ====== ابدأ الإضافة هنا (كود JavaScript) ====== --}}
@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('searchInput');
    const tableBody = document.getElementById('medicinesTable');
    const tableRows = tableBody.getElementsByTagName('tr');

    searchInput.addEventListener('keyup', function(event) {
        const searchTerm = event.target.value.toLowerCase();

        for (let i = 0; i < tableRows.length; i++) {
            const row = tableRows[i];
            
            // تجاهل الصف الذي يحتوي على "لا توجد أدوية"
            if (row.getElementsByTagName('td').length < 2) {
                continue;
            }

            // [1] هو العمود الثاني (الاسم), [3] هو العمود الرابع (الباركود)
            const medicineName = row.getElementsByTagName('td')[1].textContent.toLowerCase();
            const medicineBarcode = row.getElementsByTagName('td')[3].textContent.toLowerCase();

            // إظهار الصف إذا كان الاسم أو الباركود يحتوي على كلمة البحث
            if (medicineName.includes(searchTerm) || medicineBarcode.includes(searchTerm)) {
                row.style.display = ''; // أظهر الصف
            } else {
                row.style.display = 'none'; // أخفِ الصف
            }
        }
    });
});
</script>
@endpush
{{-- =========================================== --}}