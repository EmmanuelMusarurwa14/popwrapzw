-- PopWrapZW initial schema
-- Run this in Supabase SQL editor or psql connected to your database.

-- Enable the pgcrypto extension for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Profiles table to store user metadata and roles (owner/admin/customer)
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  email text UNIQUE,
  full_name text,
  phone text,
  role text NOT NULL DEFAULT 'customer' CHECK (role IN ('owner','admin','customer')),
  created_at timestamptz DEFAULT now()
);

-- Bookings table for customer booking requests
CREATE TABLE IF NOT EXISTS public.bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  vehicle_make text,
  vehicle_model text,
  vehicle_year int,
  service_type text,
  notes text,
  photos text[], -- store storage URLs
  preferred_date timestamptz,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rescheduled','in_progress','completed','cancelled')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Optional notifications audit table
CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid REFERENCES public.bookings(id) ON DELETE CASCADE,
  "to" text,
  channel text,
  message text,
  sent_at timestamptz DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_bookings_preferred_date ON public.bookings (preferred_date);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles (email);
