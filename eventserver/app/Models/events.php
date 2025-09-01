<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class events extends Model
{
    protected $table = 'events';
    protected $primaryKey = 'id';
    
    protected $fillable = [
    'EventTitle',
    "EventDesc",
    "EventDate",
    ];


    public function users()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
