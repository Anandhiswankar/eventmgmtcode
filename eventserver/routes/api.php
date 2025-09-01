<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\authController;
use App\Http\Controllers\eventController;

// Route::get('/user', function (Request $request) {
//     return $request->user();
// })->middleware('auth:sanctum');


// Auth Routes 

Route::post('/register',[authController::class,'Register']);
Route::post('/login',[authController::class,'Login']);
Route::post('/logout',[authController::class,'Logout'])->middleware('auth:sanctum');


// Event Routes

Route::apiResource('events',eventController::class);