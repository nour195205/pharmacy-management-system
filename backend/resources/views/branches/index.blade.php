@extends('layouts.naa')

@section('content')
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="mb-0">قائمة الفروع</h1>
            <a href="{{ route('branches.create') }}" class="btn btn-primary">
                إضافة فرع جديد
            </a>
        </div>

        {{-- شريط البحث --}}
        <div class="mb-3">
            <input type="text" id="page-search-input" class="form-control" placeholder="ابحث في الفروع...">
        </div>

        @if($branches->count() > 0)
            <table id="data-table" class="table table-bordered table-striped"> {{-- أضفنا ID هنا --}}
                <thead>
                    <tr>
                        <th>#</th>
                        <th>اسم الفرع</th>
                        <th>الموقع</th>
                        <th>تاريخ الإنشاء</th>
                        <th>تاريخ اخر تحديث</th>
                        <th>العمليات</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($branches as $branch)
                        <tr>
                            <td>{{ $branch->id }}</td>
                            <td>{{ $branch->name }}</td>
                            <td>{{ $branch->location }}</td>
                            <td>{{ $branch->created_at }}</td>
                            <td>{{ $branch->updated_at }}</td>
                            <td>
                                <a href="{{ route('branches.edit', [$branch->id]) }}" type="button"
                                    class="btn btn-warning">تعديل</a>
                                <form action="{{ route('branches.destroy', $branch->id) }}" method="POST"
                                    style="display:inline-block;" onsubmit="return confirm('هل أنت متأكد من حذف هذا الفرع؟');">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="btn btn-sm btn-danger">حذف</button>
                                </form>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        @else
            <div class="alert alert-info">لا يوجد أي فروع مسجلة حالياً.</div>
        @endif
    </div>
@endsection