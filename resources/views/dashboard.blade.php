@extends('layouts.naa')

@section('title', 'لوحة التحكم الرئيسية')

@section('content')
    <div class="container-fluid mt-4">
        {{-- بطاقات الإحصائيات السريعة --}}
        <div class="row">
            <div class="col-md-3 mb-4">
                <div class="card text-white bg-primary shadow">
                    <div class="card-body">
                        <h5 class="card-title">صافي المبيعات (اليوم)</h5>
                        <p class="card-text fs-4 fw-bold">{{ number_format($netSalesToday, 2) }} جنيه</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-4">
                <div class="card text-white bg-info shadow">
                    <div class="card-body">
                        <h5 class="card-title">صافي المشتريات (اليوم)</h5>
                        <p class="card-text fs-4 fw-bold">{{ number_format($netPurchasesToday, 2) }} جنيه</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-4">
                <div class="card text-dark bg-light shadow">
                    <div class="card-body">
                        <h5 class="card-title">عدد الأدوية المسجلة</h5>
                        <p class="card-text fs-4 fw-bold">{{ $totalMedicines }}</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-4">
                <div class="card text-dark bg-light shadow">
                    <div class="card-body">
                        <h5 class="card-title">عدد الموردين</h5>
                        <p class="card-text fs-4 fw-bold">{{ $totalSuppliers }}</p>
                    </div>
                </div>
            </div>
        </div>

        {{-- قوائم التنبيهات --}}
        <div class="row mt-3">
            {{-- أدوية على وشك النفاذ --}}
            <div class="col-md-6">
                <div class="card shadow-sm">
                    <div class="card-header bg-warning text-dark">
                        <h5 class="mb-0">تنبيه: أدوية على وشك النفاذ</h5>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            {{-- ... داخل ملف dashboard.blade.php ... --}}
                            <table class="table table-striped table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th>الدواء</th>
                                        <th class="text-center">الكمية المتبقية</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @forelse($lowStockMedicines as $stock)
                                        <tr>
                                            {{-- ====== هذا هو التعديل ====== --}}
                                            <td>{{ $stock->medicine_name }}</td>
                                            {{-- ========================== --}}
                                            <td class="text-center"><span
                                                    class="badge bg-danger">{{ rtrim(rtrim(number_format($stock->total_quantity, 2), '0'), '.') }}</span>
                                            </td>
                                        </tr>
                                    @empty
                                        <tr>
                                            <td colspan="2" class="text-center text-muted py-3">لا توجد أدوية بكميات منخفضة.
                                            </td>
                                        </tr>
                                    @endforelse
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            {{-- أدوية على وشك الانتهاء --}}
            <div class="col-md-6">
                <div class="card shadow-sm">
                    <div class="card-header bg-danger text-white">
                        <h5 class="mb-0">تنبيه: أدوية على وشك انتهاء الصلاحية (خلال 90 يومًا)</h5>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th>الدواء</th>
                                        <th>الفرع</th>
                                        <th>تاريخ الانتهاء</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @forelse($expiringSoonBatches as $batch)
                                        <tr>
                                            <td>{{ $batch->medicine->name }} (تشغيلة: {{ $batch->batch_number }})</td>
                                            <td>{{ $batch->branch->name }}</td>
                                            <td>{{ \Carbon\Carbon::parse($batch->expiry_date)->format('Y-m-d') }}</td>
                                        </tr>
                                    @empty
                                        <tr>
                                            <td colspan="3" class="text-center text-muted py-3">لا توجد أدوية ستنتهي صلاحيتها
                                                قريبًا.</td>
                                        </tr>
                                    @endforelse
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection