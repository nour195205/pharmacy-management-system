<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Report;
use App\Services\ReportService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ReportController extends Controller
{
    public function __construct(private ReportService $reportService) {}

    public function index()
    {
        $reports = Report::orderBy('report_date', 'desc')->paginate(10);
        return view('reports.index', compact('reports'));
    }

    public function generate(Request $request)
    {
        if ($request->filled('start_date') && $request->filled('end_date')) {
            $request->validate([
                'start_date' => 'required|date',
                'end_date'   => 'required|date|after_or_equal:start_date',
            ]);

            $this->reportService->generateCustomReportWeb($request->start_date, $request->end_date);
            return redirect()->route('reports.index')->with('success', 'تم إنشاء تقرير الفترة المحددة بنجاح');
        }

        $this->reportService->generateDailyReport();
        return redirect()->route('reports.index')->with('success', 'تم إنشاء التقرير اليومي بنجاح');
    }

    public function download(Report $report)
    {
        if (Storage::disk('public')->exists($report->file_path)) {
            return Storage::disk('public')->download($report->file_path);
        }
        return back()->with('error', 'الملف غير موجود');
    }
}
