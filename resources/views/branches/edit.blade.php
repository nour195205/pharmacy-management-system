@extends('layouts.naa')

@section('title', 'تعديل فرع')

@section('content')
<div class="container mt-4">
    <h1 class="mb-4">تعديل فرع</h1>

    {{-- عرض الأخطاء --}}
    @if ($errors->any())
        <div class="alert alert-danger">
            <ul class="mb-0">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('branches.update' , [$branch->id]) }}" method="POST">
        @csrf
        @method('PUT')
        <div class="mb-3">
            <label for="name" class="form-label">اسم الفرع</label>
            <input type="text" name="name" class="form-control" id="name" placeholder="أدخل اسم الفرع" value="{{ $branch->name }}" required>
        </div>

        <div class="mb-3">
            <label for="location" class="form-label">الموقع</label>
            <textarea name="location" class="form-control" id="location" placeholder="أدخل موقع الفرع" rows="3" value="{{ $branch->location }}" required></textarea>
        </div>

        <button type="submit" class="btn btn-primary">حفظ الفرع</button>
        <a href="{{ route('branches.index') }}" class="btn btn-secondary">إلغاء</a>
    </form>
</div>
@endsection
