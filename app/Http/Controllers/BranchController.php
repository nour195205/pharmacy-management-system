<?php

namespace App\Http\Controllers;
use App\Models\Branch;
use Illuminate\Http\Request;

class BranchController extends Controller
{
    public function index()
    {
        $branches = Branch::all();
        return view('branches.index', ['branches' => $branches]);
    }

    public function create(){
        return view('branches.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'location' => 'required|string',
        ]);

        Branch::create([
            'name' => $request->name,
            'location' => $request->location,
        ]);

        return redirect()->route('branches.create')->with('success', 'تم إضافة الفرع بنجاح!');
    }
    public function edit (Branch $branch){
        return view('branches.edit' ,['branch'=> $branch]);
    }

    public function update(Request $request, $branchId){
        $singlePostfromDB = Branch::find($branchId);

        $singlePostfromDB->update([
            'name' => $request->input('name'),
            'location' => $request->input('location'),
        ]);

        return redirect()->route('branches.index', $branchId);
    }


    public function destroy($branchId)
    {
        $branch = Branch::find($branchId);
        $branch->delete();
        // Logic to delete the post
        return to_route('branches.index')->with('success', 'branch deleted successfully!');
    }

}
