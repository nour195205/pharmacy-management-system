<?php

namespace App\Services;

use App\Models\Batch;
use App\Models\Branch;
use App\Models\Medicine;
use App\Models\PurchaseInvoice;
use App\Models\PurchaseInvoiceItem;
use App\Models\Supplier;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class PurchaseInvoiceService
{
    public function getPaginated(int $perPage = 10): LengthAwarePaginator
    {
        return PurchaseInvoice::with('supplier')->latest()->paginate($perPage);
    }

    public function getFormData(): array
    {
        return [
            'suppliers'  => Supplier::all(),
            'medicines'  => Medicine::all(),
            'branches'   => Branch::all(),
        ];
    }

    public function store(array $data, int $userId): PurchaseInvoice
    {
        return DB::transaction(function () use ($data, $userId) {
            $invoice = PurchaseInvoice::create([
                'branch_id'    => $data['branch_id'],
                'supplier_id'  => $data['supplier_id'],
                'user_id'      => $userId,
                'invoice_date' => $data['invoice_date'],
                'total_amount' => 0,
            ]);

            $totalAmount = 0;

            foreach ($data['items'] as $item) {
                $medicine = Medicine::findOrFail($item['medicine_id']);

                $batch = Batch::create([
                    'branch_id'        => $data['branch_id'],
                    'medicine_id'      => $medicine->id,
                    'batch_number'     => 'BATCH-' . $medicine->id . '-' . time() . '-' . rand(100, 999),
                    'manufacture_date' => $item['manufacture_date'],
                    'expiry_date'      => $item['expiry_date'],
                    'quantity'         => $item['quantity'],
                    'purchase_price'   => $item['purchase_price'],
                    'selling_price'    => $item['selling_price'],
                ]);

                PurchaseInvoiceItem::create([
                    'purchase_invoice_id' => $invoice->id,
                    'batch_id'            => $batch->id,
                    'quantity'            => $item['quantity'],
                    'qty'                 => $item['quantity'],
                    'price'              => $item['purchase_price'],
                    'purchase_price'     => $item['purchase_price'],
                    'sale_price'         => $medicine->sale_price,
                ]);

                $totalAmount += $item['quantity'] * $item['purchase_price'];
            }

            $invoice->update(['total_amount' => $totalAmount]);

            return $invoice;
        });
    }

    public function update(PurchaseInvoice $invoice, array $data): PurchaseInvoice
    {
        return DB::transaction(function () use ($invoice, $data) {
            // Delete old items and their batches
            foreach ($invoice->items as $oldItem) {
                $oldItem->batch()->delete();
                $oldItem->delete();
            }

            $totalAmount = 0;

            foreach ($data['items'] as $itemData) {
                $medicine = Medicine::findOrFail($itemData['medicine_id']);

                $batch = Batch::create([
                    'branch_id'        => $data['branch_id'],
                    'medicine_id'      => $medicine->id,
                    'batch_number'     => 'BATCH-' . $medicine->id . '-' . time() . '-' . rand(100, 999),
                    'manufacture_date' => $itemData['manufacture_date'],
                    'expiry_date'      => $itemData['expiry_date'],
                    'quantity'         => $itemData['quantity'],
                    'purchase_price'   => $itemData['purchase_price'],
                    'selling_price'    => $itemData['selling_price'],
                ]);

                PurchaseInvoiceItem::create([
                    'purchase_invoice_id' => $invoice->id,
                    'batch_id'            => $batch->id,
                    'qty'                 => $itemData['quantity'],
                    'price'              => $itemData['purchase_price'],
                    'total'              => $itemData['quantity'] * $itemData['purchase_price'],
                ]);

                $totalAmount += $itemData['quantity'] * $itemData['purchase_price'];
            }

            $invoice->update([
                'branch_id'    => $data['branch_id'],
                'supplier_id'  => $data['supplier_id'],
                'invoice_date' => $data['invoice_date'],
                'total_amount' => $totalAmount,
            ]);

            return $invoice->fresh();
        });
    }

    public function delete(PurchaseInvoice $invoice): void
    {
        DB::transaction(function () use ($invoice) {
            foreach ($invoice->items as $item) {
                $medicine = Medicine::find($item->medicine_id);
                if ($medicine) {
                    $medicine->decrement('stock_quantity', $item->quantity);
                }
            }

            $invoice->delete();
        });
    }
}
