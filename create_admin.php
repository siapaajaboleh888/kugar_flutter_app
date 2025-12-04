<?php

use Illuminate\Support\Facades\Hash;
use App\Models\User;

// Create admin user
User::create([
    'name' => 'Admin KUGAR',
    'email' => 'admin@kugar.com',
    'password' => Hash::make('admin123'),
    'role' => 'admin',
]);

echo "Admin user created successfully!\n";
echo "Email: admin@kugar.com\n";
echo "Password: admin123\n";
