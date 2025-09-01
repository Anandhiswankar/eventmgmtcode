<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class authController extends Controller
{
    public function Logout(Request $request)
    {
        $request->user()->tokens()->delete();

        return ['status'=>true, 'message'=>'Logout successful'];
    }

    public function Register(Request $request)
    {

        $registerData = $request->validate([
            'name'=>'required',
            'email'=>'required | unique:users,email',
            'password'=>'required',
            'role'=>'required | in:user,admin'
        ]);

        $user = User::create($registerData);

        $token = $user->createToken($request->email)->plainTextToken;

        return ['data'=>$registerData, 'token'=>$token];

    }

    public function Login(Request $request)
    {
        $registerData = $request->validate([
            'email'=>'required | email',
            'password'=>'required'
        ]);

        $user = User::where('email', $request->email)->first();

        if(!$user || !Hash::check($request->password, $user->password)){
            
                return ['message'=>"Invalid credentials"];
            }

        return ['status'=>true,'userdata'=>$user,'message'=>'Login successful', 'token'=>$user->createToken($request->email)->plainTextToken];
    }

 
}
