<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Check if admin already exists
        $existingAdmin = User::where('email', 'admin@kugar.com')->first();
        
        if ($existingAdmin) {
            $this->command->info('Admin user already exists!');
            return;
        }

        // Create admin user
        User::create([
            'name' => 'Admin KUGAR',
            'email' => 'admin@kugar.com',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
            'email_verified_at' => now(),
        ]);

        $this->command->info('Admin user created successfully!');
        $this->command->info('Email: admin@kugar.com');
        $this->command->info('Password: admin123');
    }
}
