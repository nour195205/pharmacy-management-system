<?php

namespace App\Services;

use App\Models\Batch;
use App\Models\Branch;
use App\Models\Customer;
use App\Models\SalesInvoice;
use App\Models\SalesInvoiceItem;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class SalesInvoiceService
{
    public function getPaginated(int $perPage = 10): LengthAwarePaginator
    {
        return SalesInvoice::with('branch', 'creator')->latest()->paginate($perPage);
    }

    public function getFormData(): array
    {
        return [
            'availableBatches' => Batch::where('quantity', '>', 0)->with('medicine', 'branch')->get(),
            'branches'         => Branch::all(),
            'customers'        => Customer::all(),
        ];
    }

    public function store(array $data, int $userId): SalesInvoice
    {
        return DB::transaction(function () use ($data, $userId) {
            $totalAmount = 0;

            // Calculate total
            foreach ($data['items'] as $itemData) {
                if (empty($itemData['quantity']) || $itemData['quantity'] <= 0) continue;
                $batch = Batch::findOrFail($itemData['batch_id']);
                $totalAmount += $itemData['quantity'] * $batch->selling_price;
            }

            if ($totalAmount <= 0) {
                throw new \Exception("يجب بيع كمية واحدة على الأقل.");
            }

            $salesInvoice = SalesInvoice::create([
                'branch_id'      => $data['branch_id'],
                'customer_id'    => $data['customer_id'] ?? null,
                'date'           => $data['date'],
                'status'         => $data['status'],
                'payment_method' => $data['payment_method'],
                'note'           => $data['note'] ?? null,
                'created_by'     => $userId,
                'total'          => $totalAmount,
            ]);

            // Process items and decrement stock
            foreach ($data['items'] as $itemData) {
                if (empty($itemData['quantity']) || $itemData['quantity'] <= 0) continue;

                $batch = Batch::findOrFail($itemData['batch_id']);
                $sellingPrice = $batch->selling_price;
                $total = $itemData['quantity'] * $sellingPrice;

                SalesInvoiceItem::create([
                    'sales_invoice_id' => $salesInvoice->id,
                    'batch_id'         => $batch->id,
                    'qty'              => $itemData['quantity'],
                    'price'            => $sellingPrice,
                    'total'            => $total,
                ]);

                $batch->decrement('quantity', $itemData['quantity']);
            }

            // Update customer balance if pending
            if (($data['customer_id'] ?? null) && $data['status'] === 'معلق') {
                $customer = Customer::find($data['customer_id']);
                if ($customer && $customer->account) {
                    $customer->account->increment('balance', $totalAmount);
                }
            }

            return $salesInvoice;
        });
    }

    public function update(SalesInvoice $salesInvoice, array $data): SalesInvoice
    {
        return DB::transaction(function () use ($salesInvoice, $data) {
            $oldTotal = $salesInvoice->total;
            $oldCustomerId = $salesInvoice->customer_id;
            $oldStatus = $salesInvoice->status;

            // Reverse old customer balance
            if ($oldCustomerId && $oldStatus === 'معلق') {
                $oldCustomer = Customer::find($oldCustomerId);
                if ($oldCustomer && $oldCustomer->account) {
                    $oldCustomer->account->decrement('balance', $oldTotal);
                }
            }

            // Restore old stock
            foreach ($salesInvoice->items as $oldItem) {
                Batch::find($oldItem->batch_id)->increment('quantity', $oldItem->qty);
            }
            $salesInvoice->items()->delete();

            $totalAmount = 0;

            // Add new items and decrement stock
            foreach ($data['items'] as $itemData) {
                if (empty($itemData['quantity']) || $itemData['quantity'] <= 0) continue;

                $batch = Batch::findOrFail($itemData['batch_id']);

                if ($itemData['quantity'] > $batch->quantity) {
                    throw new \Exception("الكمية المطلوبة للدواء {$batch->medicine->name} تتجاوز الكمية المتاحة.");
                }

                $sellingPrice = $batch->selling_price;
                $total = $itemData['quantity'] * $sellingPrice;
                $totalAmount += $total;

                SalesInvoiceItem::create([
                    'sales_invoice_id' => $salesInvoice->id,
                    'batch_id'         => $batch->id,
                    'qty'              => $itemData['quantity'],
                    'price'            => $sellingPrice,
                    'total'            => $total,
                ]);

                $batch->decrement('quantity', $itemData['quantity']);
            }

            if ($totalAmount <= 0) {
                throw new \Exception("يجب بيع كمية واحدة على الأقل.");
            }

            $salesInvoice->update([
                'branch_id'      => $data['branch_id'],
                'customer_id'    => $data['customer_id'] ?? null,
                'date'           => $data['date'],
                'status'         => $data['status'],
                'payment_method' => $data['payment_method'],
                'note'           => $data['note'] ?? null,
                'total'          => $totalAmount,
            ]);

            // Apply new customer balance
            if (($data['customer_id'] ?? null) && $data['status'] === 'معلق') {
                $newCustomer = Customer::find($data['customer_id']);
                if ($newCustomer && $newCustomer->account) {
                    $newCustomer->account->increment('balance', $totalAmount);
                }
            }

            return $salesInvoice->fresh();
        });
    }

    public function delete(SalesInvoice $salesInvoice): void
    {
        DB::transaction(function () use ($salesInvoice) {
            foreach ($salesInvoice->items as $item) {
                $batch = Batch::find($item->batch_id);
                if ($batch) {
                    $batch->increment('quantity', $item->qty);
                }
            }

            $salesInvoice->delete();
        });
    }

    public function getEditFormData(SalesInvoice $salesInvoice): array
    {
        $salesInvoice->load('items.batch.medicine');
        $currentBatchesIds = $salesInvoice->items->pluck('batch_id');

        return [
            'salesInvoice'     => $salesInvoice,
            'branches'         => Branch::all(),
            'customers'        => Customer::all(),
            'availableBatches' => Batch::where('quantity', '>', 0)
                ->orWhereIn('id', $currentBatchesIds)
                ->with('medicine', 'branch')
                ->get(),
        ];
    }
}
