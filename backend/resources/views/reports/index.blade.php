@extends('layouts.naa')

@section('title', 'التقارير اليومية')

@section('content')
<div class="container-fluid mt-4">
    <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
        <div class="p-6 text-gray-900">
            <div class="bg-light p-4 rounded mb-4 shadow-sm border">
                <div class="row align-items-center">
                    <div class="col-md-5">
                        <h4 class="font-weight-bold text-primary mb-1">توليد التقارير المخصصة واليومية</h4>
                        <p class="text-muted small mb-0">اختر فترة زمنية محددة لتوليد تقرير إحصائي مفصل للمبيعات والمخزون وحفظه في الأرشيف.</p>
                    </div>
                    <div class="col-md-7">
                        <form action="{{ route('reports.generate') }}" method="POST" class="row g-2 justify-content-end align-items-end">
                            @csrf
                            <div class="col-md-4">
                                <label for="start_date" class="form-label small text-muted mb-1 d-block text-right">من تاريخ</label>
                                <input type="date" name="start_date" id="start_date" class="form-control form-control-sm">
                            </div>
                            <div class="col-md-4">
                                <label for="end_date" class="form-label small text-muted mb-1 d-block text-right">إلى تاريخ</label>
                                <input type="date" name="end_date" id="end_date" class="form-control form-control-sm">
                            </div>
                            <div class="col-md-4 d-flex gap-2">
                                <button type="submit" class="btn btn-primary btn-sm flex-fill">
                                    توليد تقرير الفترة
                                </button>
                                <button type="submit" class="btn btn-success btn-sm flex-fill">
                                    تقرير اليوم
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <div class="d-flex justify-content-between mb-3 align-items-center">
                <h4 class="text-md font-bold text-gray-800">أرشيف التقارير المولدة</h4>
            </div>

            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead>
                        <tr>
                            <th class="text-end">تاريخ التقرير</th>
                            <th class="text-end text-center">نوع التقرير</th>
                            <th class="text-end">إجمالي المبيعات</th>
                            <th class="text-end">تحميل</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($reports as $report)
                        <tr>
                            <td>{{ $report->report_date }}</td>
                            <td class="text-center">
                                @if($report->type === 'custom')
                                    <span class="badge bg-info text-dark" style="font-size: 11px;">تقرير مخصص للفترة</span>
                                @else
                                    <span class="badge bg-success" style="font-size: 11px;">تقرير يومي</span>
                                @endif
                            </td>
                            <td>{{ number_format($report->total_sales, 2) }} ج.م</td>
                            <td>
                                <a href="{{ route('reports.download', $report->id) }}" class="btn btn-sm btn-outline-primary">
                                    تحميل PDF
                                </a>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            
            <div class="mt-4">
                {{ $reports->links() }}
            </div>
        </div>
    </div>
</div>
@endsection
