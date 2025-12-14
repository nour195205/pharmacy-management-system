@extends('layouts.naa')

@section('title', 'التقارير اليومية')

@section('content')
<div class="container-fluid mt-4">
    <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
        <div class="p-6 text-gray-900">
            <div class="d-flex justify-content-between mb-4 align-items-center">
                <h3 class="text-lg font-bold">ارشيف التقارير</h3>
                <form action="{{ route('reports.generate') }}" method="POST">
                    @csrf
                    <button type="submit" class="btn btn-primary">
                        إنشاء تقرير اليوم
                    </button>
                </form>
            </div>

            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead>
                        <tr>
                            <th class="text-end">تاريخ التقرير</th>
                            <th class="text-end">إجمالي المبيعات</th>
                            <th class="text-end">تحميل</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($reports as $report)
                        <tr>
                            <td>{{ $report->report_date }}</td>
                            <td>{{ number_format($report->total_sales, 2) }}</td>
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
