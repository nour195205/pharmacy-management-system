@extends('layouts.naa')

@section('title', 'إدارة العملاء')

@section('content')
    <div class="container mt-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1>العملاء</h1>
            <a href="{{ route('customers.create') }}" class="btn btn-primary">إضافة عميل جديد</a>
        </div>

        {{-- ====== ابدأ الإضافة هنا (حقل البحث) ====== --}}
        <div class="mb-3">
            <input type="text" id="searchInput" class="form-control" placeholder="ابحث بالاسم أو رقم الهاتف...">
        </div>
        {{-- ======================================= --}}

        <div class="card shadow-sm">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped table-hover">
                        <thead class="table-dark">
                            <tr>
                                <th>#</th>
                                <th>اسم العميل</th>
                                <th>الهاتف</th>
                                <th>العنوان</th>
                                <th class="text-end">الرصيد الحالي (مدين)</th>
                                <th>إجراءات</th>
                            </tr>
                        </thead>
                        {{-- أضفنا id للـ tbody ليسهل الوصول إليه --}}
                        <tbody id="customersTable">
                            @forelse ($customers as $customer)
                                <tr>
                                    <td>{{ $customer->id }}</td>
                                    <td>{{ $customer->name }}</td>
                                    <td>{{ $customer->phone ?? 'غير مسجل' }}</td>
                                    <td>{{ $customer->address ?? 'غير مسجل' }}</td>
                                    <td
                                        class="text-end fw-bold {{ optional($customer->account)->balance > 0 ? 'text-danger' : 'text-success' }}">
                                        {{ number_format(optional($customer->account)->balance ?? 0, 2) }} جنيه
                                    </td>
                                    <td>
                                        {{-- <a href="#" class="btn btn-sm btn-info">كشف حساب</a> --}}
                                        <a href="{{ route('customers.payments.create', $customer->id) }}"
                                            class="btn btn-sm btn-success">تسجيل دفعة</a>

                                        <a href="{{ route('customers.edit', $customer->id) }}"
                                            class="btn btn-sm btn-warning">تعديل</a>
                                        <form action="{{ route('customers.destroy', $customer->id) }}" method="POST"
                                            class="d-inline" onsubmit="return confirm('هل أنت متأكد من حذف هذا العميل؟')">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-sm btn-danger">حذف</button>
                                        </form>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="6" class="text-center py-4">لا يوجد عملاء مسجلين حتى الآن.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            @if($customers->hasPages())
                <div class="card-footer">
                    {{ $customers->links() }}
                </div>
            @endif
        </div>
    </div>
@endsection

{{-- ====== ابدأ الإضافة هنا (كود JavaScript) ====== --}}
@push('scripts')
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const searchInput = document.getElementById('searchInput');
            const tableBody = document.getElementById('customersTable');
            const tableRows = tableBody.getElementsByTagName('tr');

            searchInput.addEventListener('keyup', function (event) {
                const searchTerm = event.target.value.toLowerCase();

                for (let i = 0; i < tableRows.length; i++) {
                    const row = tableRows[i];

                    if (row.getElementsByTagName('td').length < 2) {
                        continue;
                    }

                    // [1] هو العمود الثاني (الاسم), [2] هو العمود الثالث (الهاتف)
                    const customerName = row.getElementsByTagName('td')[1].textContent.toLowerCase();
                    const customerPhone = row.getElementsByTagName('td')[2].textContent.toLowerCase();

                    // إظهار الصف إذا كان الاسم أو الهاتف يحتوي على كلمة البحث
                    if (customerName.includes(searchTerm) || customerPhone.includes(searchTerm)) {
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