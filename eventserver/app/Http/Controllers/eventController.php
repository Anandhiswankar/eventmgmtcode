<?php

namespace App\Http\Controllers;

use App\Models\events;
use Illuminate\Http\Request;
use Illuminate\Routing\Controllers\Middleware;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Support\Facades\Gate;

class eventController extends Controller implements HasMiddleware
{
    public static function middleware()
    {
        return [
            new Middleware('auth:sanctum')
        ];
    }

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $perPage = $request->query('per_page', 10);

        $events = events::paginate($perPage);
    
        return response()->json($events);
    //    return events::all();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $checkdata = $request->validate([
            'EventTitle'=> 'required|min:5',
            'EventDesc' => 'required|min:5',
            'EventDate'=> 'required|date' 
        ]);


        if(Gate::allows("checkpermission"))
        {
            $returndata = $request->user()->events()->create($checkdata);

            return ['post'=>$returndata];
        }
        else
        {
            return ["message"=>"You Don't have permissions"];
        }
       
    }

    /**
     * Display the specified resource.
     */
    public function show(events $event)
    {
        // Add some debugging
        if (!$event) {
            return ['error' => 'Event not found'];
        }
        return ['post' => $event];
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, events $event)
    {
        // Add some debugging
        if (!$event) {
            return ['error' => 'Event not found'];
        }

        $checkdata = $request->validate([
            'EventTitle'=> 'required|min:5',
            'EventDesc' => 'required|min:5',
            'EventDate'=> 'required|date' 
        ]);
    

        if(Gate::allows("checkpermission"))
        {
            $returndata = $event->update($checkdata);
    
            return ['post' => $returndata, 'message' => 'Event updated successfully'];
        }
        else
        {
            return ["message" => "You Don't have permissions"];
        }
    
         
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(events $event)
    {

        
        if(Gate::allows("checkpermission"))
        { 
        $returndata = $event->forceDelete();
        return ['message'=>"deleted","status"=>true,"data"=>$returndata];
        }
        else
        {
            return ["message"=>"You Don't have permissions"];
        }
    
      
    }
}
