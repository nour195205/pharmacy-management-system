<?php

namespace App\Services;

use App\Models\Batch;
use App\Models\PurchaseInvoice;
use App\Models\PurchaseReturn;
use App\Models\PurchaseReturnItem;
use Illuminate\Support\Facades\DB;

class PurchaseReturnService
{
    public function getPaginated(int $perPage = 10)
    {
        return PurchaseReturn::with('purchaseInvoice.supplier')->latest()->paginate($perPage);
    }

    public function getReturnedQuantities(PurchaseInvoice $invoice)
    {
        return PurchaseReturnItem::whereIn('batch_id', $invoice->items->pluck('batch_id'))
            ->groupBy('batch_id')
            ->select('batch_id', DB::raw('SUM(quantity) as total_returned'))
            ->pluck('total_returned', 'batch_id');
    }

    public function store(array $data, int $userId): PurchaseReturn
    {
        return DB::transaction(function () use ($data, $userId) {
            $invoice = PurchaseInvoice::findOrFail($data['purchase_invoice_id']);
            $totalReturnAmount = 0;
            $returnedItemsCount = 0;

            $purchaseReturn = PurchaseReturn::create([
                'purchase_invoice_id' => $invoice->id,
                'user_id'             => $userId,
                'date'                => $data['date'],
                'reason'              => $data['reason'] ?? null,
                'total'               => 0,
                'created_by'          => $userId,
            ]);

            foreach ($data['items'] as $itemData) {
                if (empty($itemData['quantity']) || $itemData['quantity'] <= 0) {
                    continue;
                }

                $returnedItemsCount++;
                $batch = Batch::findOrFail($itemData['batch_id']);

                if ($itemData['quantity'] > $batch->quantity) {
                    throw new \Exception("الكمية المرتجعة للدواء {$batch->medicine->name} تتجاوز الكمية المتاحة.");
                }

                $purchasePrice = $batch->purchase_price;
                $total = $itemData['quantity'] * $purchasePrice;
                $totalReturnAmount += $total;

                PurchaseReturnItem::create([
                    'purchase_return_id' => $purchaseReturn->id,
                    'batch_id'           => $batch->id,
                    'quantity'           => $itemData['quantity'],
                    'purchase_price'     => $purchasePrice,
                    'total'              => $total,
                ]);

                $batch->decrement('quantity', $itemData['quantity']);
            }

            if ($returnedItemsCount === 0) {
                throw new \Exception("يجب إرجاع كمية واحدة على الأقل.");
            }

            $purchaseReturn->update(['total' => $totalReturnAmount]);

            return $purchaseReturn;
        });
    }
}
