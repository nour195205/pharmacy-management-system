<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreSalesReturnRequest;
use App\Models\SalesInvoice;
use App\Models\SalesReturn;
use App\Services\SalesReturnService;
use Illuminate\Http\Request;

class SalesReturnController extends Controller
{
    public function __construct(private SalesReturnService $salesReturnService) {}

    public function index()
    {
        $returns = $this->salesReturnService->getPaginated();
        return view('sales_returns.index', compact('returns'));
    }

    public function create(Request $request)
    {
        $invoice_id = $request->query('invoice_id');

        if (!$invoice_id) {
            $invoices = SalesInvoice::latest()->get();
            return view('sales_returns.select_invoice', compact('invoices'));
        }

        $invoice = SalesInvoice::with('items.batch.medicine')->findOrFail($invoice_id);
        return view('sales_returns.create', compact('invoice'));
    }

    public function store(StoreSalesReturnRequest $request)
    {
        try {
            $this->salesReturnService->store($request->validated(), auth()->id());
            return redirect()->route('sales-returns.index')
                ->with('success', 'تم تسجيل مرتجع المبيعات بنجاح.');
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'حدث خطأ: ' . $e->getMessage())
                ->withInput();
        }
    }

    public function show(SalesReturn $salesReturn)
    {
        $salesReturn->load('items.batch.medicine', 'salesInvoice', 'creator');
        return view('sales_returns.show', compact('salesReturn'));
    }

    public function receipt(SalesReturn $salesReturn)
    {
        $salesReturn->load('items.batch.medicine', 'salesInvoice', 'creator');
        return view('sales_returns.receipt', compact('salesReturn'));
    }
}
