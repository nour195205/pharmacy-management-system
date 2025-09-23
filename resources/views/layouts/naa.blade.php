<!DOCTYPE html>
<html lang="ar">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'نظام إدارة الصيدليات')</title>

    {{-- Bootstrap CSS --}}
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    {{-- Select2 CSS --}}
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />

    {{-- Custom CSS --}}
    <link href="{{ asset('css/app.css') }}" rel="stylesheet">

    @stack('styles')
</head>

<body class="d-flex flex-column min-vh-100 bg-light">

    {{-- Navbar --}}
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm">
        <div class="container-fluid">
            <a class="navbar-brand fw-bold" href="{{ route('dashboard') }}">نظام الصيدلية</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav"
                aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                    <li class="nav-item">
                        <a class="nav-link active" aria-current="page" href="{{ route('dashboard') }}">الرئيسية</a>
                    </li>

                    {{-- قائمة المخزون --}}
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="inventoryDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            المخزون
                        </a>
                        <ul class="dropdown-menu" aria-labelledby="inventoryDropdown">
                            <li><a class="dropdown-item" href="{{ route('medicines.index') }}">الأدوية</a></li>
                            <li><a class="dropdown-item" href="{{ route('batches.index') }}">التشغيلات (المخزون الفعلي)</a></li>
                        </ul>
                    </li>

                    {{-- قائمة المشتريات --}}
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="purchasesDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            المشتريات
                        </a>
                        <ul class="dropdown-menu" aria-labelledby="purchasesDropdown">
                            <li><a class="dropdown-item" href="{{ route('purchase-invoices.index') }}">فواتير المشتريات</a></li>
                            <li><a class="dropdown-item" href="{{ route('purchase-returns.index') }}">مرتجعات المشتريات</a></li>
                        </ul>
                    </li>

                    {{-- قائمة المبيعات --}}
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="salesDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            المبيعات
                        </a>
                        <ul class="dropdown-menu" aria-labelledby="salesDropdown">
                            <li><a class="dropdown-item" href="{{ route('sales-invoices.index') }}">فواتير المبيعات</a></li>
                            <li><a class="dropdown-item" href="{{ route('sales-returns.index') }}">مرتجعات المبيعات</a></li>
                        </ul>
                    </li>

                    {{-- قائمة البيانات الأساسية --}}
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="coreDataDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            البيانات الأساسية
                        </a>
                        <ul class="dropdown-menu" aria-labelledby="coreDataDropdown">
                            <li><a class="dropdown-item" href="{{ route('branches.index') }}">الفروع</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="{{ route('suppliers.index') }}">الموردين</a></li>
                            <li><a class="dropdown-item" href="{{ route('customers.index') }}">العملاء</a></li>
                        </ul>
                    </li>
                </ul>

                {{-- الجزء الخاص بالمستخدم وتسجيل الخروج --}}
                <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
                    @auth
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            {{ Auth::user()->name }}
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                            <li><a class="dropdown-item" href="{{ route('profile.edit') }}">الملف الشخصي</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li>
                                <form method="POST" action="{{ route('logout') }}">
                                    @csrf
                                    <button type="submit" class="dropdown-item">تسجيل الخروج</button>
                                </form>
                            </li>
                        </ul>
                    </li>
                    @endauth
                </ul>
            </div>
        </div>
    </nav>


    {{-- محتوى الصفحة --}}
    <main class="flex-fill py-4">
        <div class="container">
            @if (session('success'))
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    {{ session('success') }}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            @endif
            @if (session('error'))
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    {{ session('error') }}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            @endif
        </div>
        @yield('content')
    </main>

    {{-- Footer --}}
    <footer class="bg-dark text-white mt-auto py-3">
        <div class="container text-center">
            &copy; {{ date('Y') }} جميع الحقوق محفوظة
        </div>
    </footer>

    {{-- jQuery (يجب أن يكون قبل Bootstrap و Select2) --}}
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    {{-- Bootstrap JS --}}
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    {{-- Select2 JS --}}
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    
    @stack('scripts')

    {{-- ... أكواد JS الحالية مثل jQuery و Bootstrap تبقى كما هي ... --}}
    @stack('scripts')

    {{-- ==================== ابدأ بإضافة الكود التالي ==================== --}}
    <script>
        $(document).ready(function() {
            // === الجزء الأول: تفعيل اختصار F1 للتركيز على البحث ===
            $(document).on('keydown', function(e) {
                // لا تفعل شيئاً إذا كان المستخدم يكتب بالفعل في أي حقل
                if ($(e.target).is('input, textarea, select')) {
                    return;
                }
                // عند الضغط على F1
                if (e.key === 'F1') {
                    e.preventDefault(); // منع السلوك الافتراضي للزر (فتح المساعدة)

                    const searchInput = $('#page-search-input');
                    if (searchInput.length > 0) {
                        searchInput.focus(); // قم بالتركيز على حقل البحث العادي
                    }
                }
            });

            // === الجزء الثاني: تنفيذ البحث الفوري في الجداول العادية ===
            const searchInput = $('#page-search-input');
            if (searchInput.length > 0) {
                searchInput.on('keyup input', function() {
                    const searchTerm = $(this).val().toLowerCase();
                    
                    // ابحث في كل صف من صفوف الجدول المستهدف
                    $('#data-table tbody tr').each(function() {
                        const rowText = $(this).text().toLowerCase();
                        
                        // إذا كان نص الصف يحتوي على كلمة البحث، أظهره، وإلا أخفه
                        if (rowText.includes(searchTerm)) {
                            $(this).show();
                        } else {
                            $(this).hide();
                        }
                    });
                });
            }
        });
    </script>
    {{-- ==================== انتهى الكود المضاف ==================== --}}


</body>

</html>