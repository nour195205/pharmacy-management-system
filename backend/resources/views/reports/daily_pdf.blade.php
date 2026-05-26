<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>Daily Report</title>
    <style>
        body { font-family: sans-serif; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: right; }
        th { background-color: #f2f2f2; }
        .header { text-align: center; margin-bottom: 30px; }
        .summary { margin-bottom: 20px; }
        .section-title { font-size: 18px; font-weight: bold; margin-top: 20px; decoration: underline; }
    </style>
</head>
<body>
    <div class="header">
        <h1>تقرير الصيدلية اليومي</h1>
        <p>التاريخ: {{ $date }}</p>
    </div>

    <div class="summary">
        <h3>ملخص اليوم</h3>
        <p><strong>إجمالي المبيعات:</strong> {{ number_format($total_sales, 2) }} ج.م</p>
        <p><strong>عدد العمليات:</strong> {{ $total_transactions }}</p>
    </div>

    <div class="section-title">قائمة المبيعات</div>
    <table>
        <thead>
            <tr>
                <th>رقم الفاتورة</th>
                <th>الوقت</th>
                <th>الإجمالي</th>
                <th>الحالة</th>
            </tr>
        </thead>
        <tbody>
            @foreach($sales_list as $invoice)
            <tr>
                <td>{{ $invoice->id }}</td>
                <td>{{ $invoice->created_at->format('H:i') }}</td>
                <td>{{ number_format($invoice->total, 2) }}</td>
                <td>{{ $invoice->status }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>

    @if($low_stock->count() > 0)
    <div class="section-title" style="color: red;">تنبيهات المخزون (نواقص)</div>
    <table>
        <thead>
            <tr>
                <th>الدواء</th>
                <th>الكمية المتبقية</th>
            </tr>
        </thead>
        <tbody>
            @foreach($low_stock as $batch)
            <tr>
                <td>{{ $batch->medicine->name ?? 'غير معروف' }}</td>
                <td>{{ $batch->quantity }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>
    @endif

    @if($expiring->count() > 0)
    <div class="section-title" style="color: orange;">تنبيهات الصلاحية (قرب الانتهاء)</div>
    <table>
        <thead>
            <tr>
                <th>الدواء</th>
                <th>تاريخ الانتهاء</th>
                <th>الكمية</th>
            </tr>
        </thead>
        <tbody>
            @foreach($expiring as $batch)
            <tr>
                <td>{{ $batch->medicine->name ?? 'غير معروف' }}</td>
                <td>{{ $batch->expiry_date }}</td>
                <td>{{ $batch->quantity }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>
    @endif
</body>
</html>
