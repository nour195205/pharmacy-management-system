<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>فاتورة مشتريات رقم #{{ $purchaseInvoice->id }}</title>
    {{-- Bootstrap CSS for printing --}}
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        @media print {
            /* إخفاء الأزرار عند الطباعة */
            .no-print {
                display: none !important;
            }
            body {
                -webkit-print-color-adjust: exact; /* لضمان طباعة الألوان والخلفيات في Chrome */
                print-color-adjust: exact;
            }
        }
        body {
            background-color: #f8f9fa;
        }
        .invoice-container {
            background-color: #fff;
            border: 1px solid #dee2e6;
            border-radius: .25rem;
        }
    </style>
</head>
<body class="py-4">

    <div class="container">
        <div class="d-flex justify-content-end mb-3 no-print">
            <button onclick="window.print()" class="btn btn-primary">طباعة الفاتورة</button>
            <a href="{{ route('purchase-invoices.show', $purchaseInvoice->id) }}" class="btn btn-secondary ms-2">العودة للتفاصيل</a>
        </div>

        <div class="p-5 invoice-container" id="invoice-to-print">
            {{-- ترويسة الفاتورة --}}
            <div class="row d-flex align-items-center pb-4 border-bottom">
                <div class="col-md-6">
                    <h1 class="h2">فاتورة مشتريات</h1>
                    <p class="mb-0"><strong>فاتورة رقم:</strong> #{{ $purchaseInvoice->id }}</p>
                </div>
                <div class="col-md-6 text-md-end">
                    <h4>نظام إدارة الصيدلية</h4>
                    <p class="mb-0"><strong>تاريخ الفاتورة:</strong> {{ \Carbon\Carbon::parse($purchaseInvoice->invoice_date)->format('Y-m-d') }}</p>
                </div>
            </div>

            {{-- معلومات الفرع والمورد --}}
            <div class="row py-4 border-bottom">
                <div class="col-md-6">
                    <h5>فاتورة إلى (الفرع):</h5>
                    <ul class="list-unstyled">
                        <li><strong>{{ $purchaseInvoice->branch->name }}</strong></li>
                        <li>{{ $purchaseInvoice->branch->address }}</li>
                        <li>هاتف: {{ $purchaseInvoice->branch->phone }}</li>
                    </ul>
                </div>
                <div class="col-md-6 text-md-end">
                    <h5>فاتورة من (المورد):</h5>
                    <ul class="list-unstyled">
                        <li><strong>{{ $purchaseInvoice->supplier->name }}</strong></li>
                        <li>{{ $purchaseInvoice->supplier->address }}</li>
                        <li>هاتف: {{ $purchaseInvoice->supplier->phone }}</li>
                    </ul>
                </div>
            </div>

            {{-- جدول بنود الفاتورة --}}
            <div class="table-responsive mt-4">
                <table class="table table-bordered">
                    <thead class="bg-light">
                        <tr>
                            <th>الدواء</th>
                            <th>رقم التشغيلة</th>
                            <th>الكمية</th>
                            <th>سعر الشراء</th>
                            <th>سعر البيع</th>
                            <th class="text-end">الإجمالي الجزئي</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($purchaseInvoice->items as $item)
                            <tr>
                                <td>{{ $item->batch->medicine->name }}</td>
                                <td>{{ $item->batch->batch_number }}</td>
                                <td>{{ $item->qty }}</td>
                                <td>{{ number_format($item->price, 2) }}</td>
                                <td>{{ number_format($item->batch->selling_price, 2) }}</td>
                                <td class="text-end">{{ number_format($item->total, 2) }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="5" class="text-end fw-bold border-0"><h4>الإجمالي النهائي</h4></td>
                            <td class="text-end fw-bold border-0 bg-light"><h4>{{ number_format($purchaseInvoice->total_amount, 2) }} جنيه</h4></td>
                        </tr>
                    </tfoot>
                </table>
            </div>

            {{-- معلومات إضافية وتوقيع --}}
            <div class="row mt-5">
                <div class="col-7">
                    <p class="text-muted small"><strong>ملاحظات:</strong> تم إنشاء هذه الفاتورة بواسطة المستخدم: {{ $purchaseInvoice->user->name }}</p>
                </div>
                <div class="col-5 text-center">
                    <p>-----------------------------------</p>
                    <p class="fw-bold">توقيع المستلم</p>
                </div>
            </div>
        </div>
    </div>

</body>
</html>