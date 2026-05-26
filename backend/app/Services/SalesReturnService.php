<?php

namespace App\Services;

use App\Models\Batch;
use App\Models\SalesInvoice;
use App\Models\SalesInvoiceItem;
use App\Models\SalesReturn;
use App\Models\SalesReturnItem;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class SalesReturnService
{
    public function getPaginated(int $perPage = 10): LengthAwarePaginator
    {
        return SalesReturn::with('salesInvoice.branch', 'creator')->latest()->paginate($perPage);
    }

    public function store(array $data, int $userId): SalesReturn
    {
        return DB::transaction(function () use ($data, $userId) {
            $invoice = SalesInvoice::findOrFail($data['sales_invoice_id']);
            $totalReturnAmount = 0;
            $returnedItemsCount = 0;

            $salesReturn = SalesReturn::create([
                'sales_invoice_id' => $invoice->id,
                'date'             => $data['date'],
                'reason'           => $data['reason'] ?? null,
                'created_by'       => $userId,
                'total'            => 0,
            ]);

            foreach ($data['items'] as $itemData) {
                if (empty($itemData['quantity']) || $itemData['quantity'] <= 0) {
                    continue;
                }

                $returnedItemsCount++;

                $salesItem = SalesInvoiceItem::findOrFail($itemData['sales_item_id']);
                $batch = $salesItem->batch;

                if ($itemData['quantity'] > $salesItem->qty) {
                    throw new \Exception("الكمية المرتجعة للدواء {$batch->medicine->name} تتجاوز الكمية المباعة.");
                }

                $sellingPrice = $salesItem->price;
                $total = $itemData['quantity'] * $sellingPrice;
                $totalReturnAmount += $total;

                SalesReturnItem::create([
                    'sales_return_id' => $salesReturn->id,
                    'batch_id'        => $batch->id,
                    'quantity'        => $itemData['quantity'],
                    'selling_price'   => $sellingPrice,
                    'total'           => $total,
                ]);

                $batch->increment('quantity', $itemData['quantity']);
            }

            if ($returnedItemsCount === 0) {
                throw new \Exception("يجب إرجاع كمية واحدة على الأقل من منتج واحد لإتمام العملية.");
            }

            $salesReturn->update(['total' => $totalReturnAmount]);

            return $salesReturn;
        });
    }
}
