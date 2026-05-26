@extends('layouts.naa')

@section('title', 'إضافة مورد جديد')

@section('content')
<div class="container mt-4">

    <h1 class="mb-4">إضافة مورد جديد</h1>

    {{-- عرض أي أخطاء --}}
    @if($errors->any())
        <div class="alert alert-danger">
            <ul class="mb-0">
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('suppliers.store') }}" method="POST">
        @csrf

        <div class="mb-3">
            <label for="name" class="form-label">اسم المورد</label>
            <input type="text" class="form-control" id="name" name="name" value="{{ old('name') }}" required>
        </div>

        <div class="mb-3">
            <label for="contact_info" class="form-label">معلومات الاتصال</label>
            <input type="text" class="form-control" id="contact_info" name="contact_info" value="{{ old('contact_info') }}">
        </div>

        <div class="mb-3">
            <label for="address" class="form-label">العنوان</label>
            <input type="text" class="form-control" id="address" name="address" value="{{ old('address') }}">
        </div>

        <div class="mb-3">
            <label for="phone" class="form-label">رقم الهاتف</label>
            <input type="text" class="form-control" id="phone" name="phone" value="{{ old('phone') }}">
        </div>

        <div class="mb-3">
            <label for="email" class="form-label">البريد الإلكتروني</label>
            <input type="email" class="form-control" id="email" name="email" value="{{ old('email') }}">
        </div>

        <div class="mb-3">
            <label for="balance" class="form-label">الرصيد</label>
            <input type="number" class="form-control" id="balance" name="balance" value="{{ old('balance', 0) }}">
        </div>

        <button type="submit" class="btn btn-success">حفظ المورد</button>
        <a href="{{ route('suppliers.index') }}" class="btn btn-secondary">رجوع</a>
    </form>

</div>
@endsection
