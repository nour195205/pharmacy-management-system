<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\StorePurchaseReturnRequest;
use App\Models\PurchaseInvoice;
use App\Services\PurchaseReturnService;
use Illuminate\Http\Request;

class PurchaseReturnController extends Controller
{
    public function __construct(private PurchaseReturnService $purchaseReturnService) {}

    public function index()
    {
        $returns = $this->purchaseReturnService->getPaginated();
        return view('purchase_returns.index', compact('returns'));
    }

    public function create(Request $request)
    {
        $invoice_id = $request->query('invoice_id');

        if (!$invoice_id) {
            $invoices = PurchaseInvoice::with('supplier')->latest()->get();
            return view('purchase_returns.select_invoice', compact('invoices'));
        }

        $invoice = PurchaseInvoice::with('items.batch.medicine')->findOrFail($invoice_id);
        $returnedQuantities = $this->purchaseReturnService->getReturnedQuantities($invoice);

        return view('purchase_returns.create', compact('invoice', 'returnedQuantities'));
    }

    public function store(StorePurchaseReturnRequest $request)
    {
        try {
            $this->purchaseReturnService->store($request->validated(), auth()->id());
            return redirect()->route('purchase-returns.index')
                ->with('success', 'تم تسجيل فاتورة المرتجع بنجاح!');
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'حدث خطأ: ' . $e->getMessage())
                ->withInput();
        }
    }
}
