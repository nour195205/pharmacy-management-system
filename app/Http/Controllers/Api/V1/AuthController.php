<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    use ApiResponse;

    /**
     * Login and return a token.
     * Ready for Laravel Sanctum — install sanctum and uncomment createToken().
     */
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['بيانات الدخول غير صحيحة.'],
            ]);
        }

        // Uncomment after installing Sanctum:
        // $token = $user->createToken('mobile-app')->plainTextToken;

        return $this->success([
            'user'  => [
                'id'    => $user->id,
                'name'  => $user->name,
                'email' => $user->email,
            ],
            // 'token' => $token, // Uncomment after Sanctum
        ], 'تم تسجيل الدخول بنجاح');
    }

    /**
     * Logout — revoke token.
     * Requires Sanctum middleware.
     */
    public function logout(Request $request)
    {
        // Uncomment after installing Sanctum:
        // $request->user()->currentAccessToken()->delete();

        return $this->success(null, 'تم تسجيل الخروج بنجاح');
    }
}
