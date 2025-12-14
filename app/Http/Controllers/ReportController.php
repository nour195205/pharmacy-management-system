<?php

namespace App\Http\Controllers;

use App\Models\Report;
use App\Services\ReportService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ReportController extends Controller
{
    protected $reportService;

    public function __construct(ReportService $reportService)
    {
        $this->reportService = $reportService;
    }

    public function index()
    {
        $reports = Report::orderBy('report_date', 'desc')->paginate(10);
        return view('reports.index', compact('reports'));
    }

    public function generate(Request $request)
    {
        $report = $this->reportService->generateDailyReport();
        return redirect()->route('reports.index')->with('success', 'تم إنشاء التقرير بنجاح');
    }

    public function download(Report $report)
    {
        if (Storage::disk('public')->exists($report->file_path)) {
            return Storage::disk('public')->download($report->file_path);
        }
        return back()->with('error', 'الملف غير موجود');
    }
}
