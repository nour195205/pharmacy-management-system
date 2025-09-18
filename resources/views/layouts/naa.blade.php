<!DOCTYPE html>
<html lang="ar">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'نظام إدارة الفروع')</title>

    {{-- Bootstrap CSS --}}
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    {{-- CSS مخصص --}}
    <link href="{{ asset('css/app.css') }}" rel="stylesheet">

    @stack('styles')
</head>

<body class="d-flex flex-column min-vh-100">

    {{-- Navbar --}}
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="{{ url('/') }}">نظام الإدارة</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav"
                aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="{{ route('branches.index') }}">الفروع</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="{{ route('suppliers.index') }}">الموردين</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="{{ route('medicines.index') }}">الادويه</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="{{ route('batches.index') }}">التشغيله</a>
                    </li>
                    {{-- ====== الزر الجديد الذي تمت إضافته ====== --}}
                    <li class="nav-item">
                        <a class="nav-link" href="{{ route('purchase-invoices.index') }}">المشتريات</a>
                    </li>
                    {{-- ========================================== --}}
                    <li class="nav-item">
                        <a class="nav-link" href="{{ route('purchase-returns.index') }}">مرتجعات المشتريات</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="{{ route('sales-invoices.index') }}">المبيعات</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="{{ route('sales-returns.index') }}">مرتجعات المبيعات</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="{{ url('/about') }}">عن النظام</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="{{ url('/contact') }}">تواصل معنا</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>


    {{-- محتوى الصفحة --}}
    <main class="flex-fill">
        <div class="container">
            @if (session('success'))
                <div class="alert alert-success mt-4">
                    {{ session('success') }}
                </div>
            @endif
            @if (session('error'))
                <div class="alert alert-danger mt-4">
                    {{ session('error') }}
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

    {{-- Bootstrap JS --}}
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    @stack('scripts')
</body>

</html>