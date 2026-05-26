@extends('layouts.naa')

@section('title', 'تعديل مورد')

@section('content')
<div class="container mt-4">

    <h1 class="mb-4">تعديل مورد</h1>

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

    <form action="{{ route('suppliers.update' , [$supplier->id]) }}" method="POST">
        @csrf
        @method('PUT')
        <div class="mb-3">
            <label for="name" class="form-label">اسم المورد</label>
            <input type="text" class="form-control" id="name" name="name" value="{{ $supplier->name }}" required>
        </div>

        <div class="mb-3">
            <label for="contact_info" class="form-label">معلومات الاتصال</label>
            <input type="text" class="form-control" id="contact_info" name="contact_info" value="{{ $supplier->contact_info }}">
        </div>

        <div class="mb-3">
            <label for="address" class="form-label">العنوان</label>
            <input type="text" class="form-control" id="address" name="address" value="{{ $supplier->address }}">
        </div>

        <div class="mb-3">
            <label for="phone" class="form-label">رقم الهاتف</label>
            <input type="text" class="form-control" id="phone" name="phone" value="{{ $supplier->phone }}">
        </div>

        <div class="mb-3">
            <label for="email" class="form-label">البريد الإلكتروني</label>
            <input type="email" class="form-control" id="email" name="email" value="{{ $supplier->email }}">
        </div>

        <div class="mb-3">
            <label for="balance" class="form-label">الرصيد</label>
            <input type="number" class="form-control" id="balance" name="balance" value="{{ $supplier->balance }}">
        </div>

        <button type="submit" class="btn btn-success">حفظ المورد</button>
        <a href="{{ route('suppliers.index') }}" class="btn btn-secondary">رجوع</a>
    </form>

</div>
@endsection
