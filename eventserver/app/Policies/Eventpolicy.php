<?php

namespace App\Policies;

use App\Models\User;
use App\Models\events;


class EventPolicy
{
 
    public function checkpermission(User $user): bool
    {
        return $user->role==='admin';
    }
}
