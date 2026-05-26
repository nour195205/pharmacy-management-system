<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\DashboardService;
use App\Traits\ApiResponse;

class DashboardController extends Controller
{
    use ApiResponse;

    public function __construct(private DashboardService $dashboardService) {}

    public function index()
    {
        $data = $this->dashboardService->getDashboardData();
        return $this->success($data, 'تم جلب بيانات لوحة التحكم بنجاح');
    }
}
