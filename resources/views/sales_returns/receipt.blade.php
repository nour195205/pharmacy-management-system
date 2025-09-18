<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>وصل مرتجع رقم #{{ $salesReturn->id }}</title>
    <style>
        @font-face {
            font-family: 'Cutive Mono', monospace;
            src: url('https://fonts.googleapis.com/css2?family=Cutive+Mono&display=swap');
        }
        
        body {
            font-family: 'Cutive Mono', monospace;
            background-color: #f0f0f0;
            display: flex;
            justify-content: center;
            padding: 20px;
            font-size: 14px;
        }
        .receipt {
            width: 302px;
            background-color: #fff;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            border-bottom: 1px dashed #000;
            padding-bottom: 10px;
            margin-bottom: 10px;
        }
        .header h4, .header p {
            margin: 0;
        }
        .details-table, .items-table {
            width: 100%;
            border-collapse: collapse;
        }
        .details-table td {
            padding: 2px 0;
        }
        .items-table th, .items-table td {
            padding: 5px 0;
            border-bottom: 1px dashed #ccc;
        }
        .items-table thead th {
            border-bottom: 1px solid #000;
        }
        .items-table .price, .items-table .total, .summary-table td:last-child {
            text-align: left;
        }
        .summary-table {
            width: 100%;
            margin-top: 10px;
            border-top: 1px solid #000;
        }
        .summary-table td {
            padding: 2px 0;
        }
        .summary-table .grand-total {
            font-size: 1.2em;
            font-weight: bold;
        }
        .footer {
            text-align: center;
            margin-top: 20px;
            font-size: 0.9em;
        }
        .no-print {
            text-align: center;
            margin-bottom: 20px;
        }
        .no-print button {
            padding: 10px 20px;
            cursor: pointer;
        }
        @media print {
            body { background-color: #fff; padding: 0; }
            .no-print { display: none; }
            .receipt { width: 100%; box-shadow: none; margin: 0; }
        }
    </style>
</head>
<body>
    <div>
        <div class="no-print">
            <button onclick="window.print()">طباعة الوصل</button>
        </div>
        <div class="receipt">
            <div class="header">
                <h4>إشعار مرتجع مبيعات</h4>
                <p>{{ $salesReturn->salesInvoice->branch->name }}</p>
            </div>
            
            <table class="details-table">
                <tr>
                    <td>رقم المرتجع:</td>
                    <td>#{{ $salesReturn->id }}</td>
                </tr>
                <tr>
                    <td>الفاتورة الأصلية:</td>
                    <td>#{{ $salesReturn->sales_invoice_id }}</td>
                </tr>
                <tr>
                    <td>التاريخ:</td>
                    <td>{{ \Carbon\Carbon::parse($salesReturn->date)->format('Y-m-d H:i') }}</td>
                </tr>
                <tr>
                    <td>تم بواسطة:</td>
                    <td>{{ $salesReturn->creator->name }}</td>
                </tr>
            </table>

            <table class="items-table">
                <thead>
                    <tr>
                        <th>الصنف المرتجع</th>
                        <th>الكمية</th>
                        <th>السعر</th>
                        <th class="total">الإجمالي</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($salesReturn->items as $item)
                    <tr>
                        <td colspan="4">{{ $item->batch->medicine->name }}</td>
                    </tr>
                    <tr>
                        <td></td>
                        <td>{{ rtrim(rtrim(number_format($item->quantity, 2), '0'), '.') }}</td>
                        <td>{{ number_format($item->selling_price, 2) }}</td>
                        <td class="total">{{ number_format($item->total, 2) }}</td>
                    </tr>
                    @endforeach
                </tbody>
            </table>

            <table class="summary-table">
                <tr>
                    <td>إجمالي المبلغ المسترجع:</td>
                    <td class="grand-total">{{ number_format($salesReturn->total, 2) }} جنيه</td>
                </tr>
            </table>

            <div class="footer">
                <p>نعتز بخدمتكم!</p>
            </div>
        </div>
    </div>
</body>
</html>