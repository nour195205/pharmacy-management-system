<?php

namespace App\Traits;

trait ApiResponse
{
    protected function success($data = null, string $message = null, int $code = 200)
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data'    => $data,
        ], $code);
    }

    protected function created($data = null, string $message = null)
    {
        return $this->success($data, $message, 201);
    }

    protected function noContent()
    {
        return response()->json(null, 204);
    }

    protected function error(string $message, int $code = 400, array $errors = [])
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors'  => $errors,
        ], $code);
    }
}
