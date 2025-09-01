<?php

namespace App\Providers;

use App\Models\events;          
use App\Policies\EventPolicy;    
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;

class AuthServiceProvider extends ServiceProvider
{
    protected $policies = [
        events::class => EventPolicy::class,
    ];

    public function boot(): void
    {
        $this->registerPolicies();

        Gate::define('checkpermission', function ($user) {
            return $user->role === 'admin';
        });
    }
}
