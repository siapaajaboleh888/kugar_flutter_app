#!/usr/bin/env php
<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

echo "Updating admin user...\n";

$user = User::where('email', 'admin@kugar.com')->first();

if ($user) {
    $user->role = 'admin';
    $user->password = Hash::make('admin123');
    $user->save();
    
    echo "✅ Admin user updated successfully!\n";
    echo "Email: admin@kugar.com\n";
    echo "Password: admin123\n";
    echo "Role: admin\n";
} else {
    echo "❌ User not found. Creating new admin user...\n";
    
    User::create([
        'name' => 'Admin KUGAR',
        'email' => 'admin@kugar.com',
        'password' => Hash::make('admin123'),
        'role' => 'admin',
        'email_verified_at' => now(),
    ]);
    
    echo "✅ Admin user created successfully!\n";
    echo "Email: admin@kugar.com\n";
    echo "Password: admin123\n";
    echo "Role: admin\n";
}
