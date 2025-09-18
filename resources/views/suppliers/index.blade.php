@extends('layouts.naa')

@section('title', 'قائمة الموردين')

@section('content')
    <div class="container mt-4">

        {{-- العنوان + زر إضافة --}}
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="mb-0">قائمة الموردين</h1>
            <a href="{{ route('suppliers.create') }}" class="btn btn-primary">
                إضافة مورد جديد
            </a>
        </div>

        {{-- ====== ابدأ الإضافة هنا (حقل البحث) ====== --}}
        <div class="mb-3">
            <input type="text" id="searchInput" class="form-control" placeholder="ابحث عن أي معلومة تخص المورد...">
        </div>
        {{-- ======================================= --}}


        {{-- جدول الموردين --}}
        <div class="card shadow-sm">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-bordered table-striped table-hover">
                        <thead class="table-primary">
                            <tr>
                                <th>#</th>
                                <th>الاسم</th>
                                <th>معلومات الاتصال</th>
                                <th>العنوان</th>
                                <th>الهاتف</th>
                                <th>البريد الإلكتروني</th>
                                <th>الرصيد</th>
                                <th>الإجراءات</th>
                            </tr>
                        </thead>
                        <tbody id="suppliersTable">
                            @forelse($suppliers as $supplier)
                                <tr>
                                    <td>{{ $supplier->id }}</td>
                                    <td>{{ $supplier->name }}</td>
                                    <td>{{ $supplier->contact_info ?? '-' }}</td>
                                    <td>{{ $supplier->address ?? '-' }}</td>
                                    <td>{{ $supplier->phone ?? '-' }}</td>
                                    <td>{{ $supplier->email ?? '-' }}</td>
                                    <td>{{ $supplier->balance }}</td>
                                    <td class="d-flex gap-2">
                                        <a href="{{ route('suppliers.edit', $supplier->id) }}" class="btn btn-sm btn-warning">تعديل</a>
                                        <form action="{{ route('suppliers.destroy', $supplier->id) }}" method="POST"
                                            onsubmit="return confirm('هل أنت متأكد من الحذف؟');">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-sm btn-danger">حذف</button>
                                        </form>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="8" class="text-center">لا يوجد موردون مسجلون</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('searchInput');
    const tableBody = document.getElementById('suppliersTable');
    const tableRows = tableBody.getElementsByTagName('tr');

    searchInput.addEventListener('keyup', function(event) {
        const searchTerm = event.target.value.toLowerCase();

        for (let i = 0; i < tableRows.length; i++) {
            const row = tableRows[i];
            const rowText = row.textContent.toLowerCase(); // <-- السطر السحري هنا

            // إظهار الصف إذا كان أي نص بداخله يحتوي على كلمة البحث
            if (rowText.includes(searchTerm)) {
                row.style.display = ''; // أظهر الصف
            } else {
                row.style.display = 'none'; // أخفِ الصف
            }
        }
    });
});
</script>
@endpush