-- =========================================================================
-- DEAR LOTTERY APP - SUPABASE SQL SCHEMA AND RLS POLICIES
-- =========================================================================

-- 1. Create Tables

-- USERS Table
-- Links to Supabase's built-in auth.users table
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone_number TEXT NOT NULL,
  is_admin BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- DRAWS Table
-- Stores the available lottery draws
CREATE TABLE IF NOT EXISTS public.draws (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  draw_date TIMESTAMP WITH TIME ZONE NOT NULL,
  ticket_price NUMERIC(10, 2) NOT NULL,
  result TEXT, -- Comma separated winning numbers or JSON
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TICKETS Table
-- Stores the purchased tickets
CREATE TABLE IF NOT EXISTS public.tickets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  draw_id UUID NOT NULL REFERENCES public.draws(id) ON DELETE CASCADE,
  ticket_number TEXT NOT NULL,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'won', 'lost')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- PAYMENTS Table
-- Stores transaction records
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  amount NUMERIC(10, 2) NOT NULL,
  payment_method TEXT DEFAULT 'Razorpay',
  status TEXT DEFAULT 'success' CHECK (status IN ('pending', 'success', 'failed')),
  razorpay_payment_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =========================================================================
-- 2. Enable Row Level Security (RLS)
-- =========================================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.draws ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- =========================================================================
-- 3. Create RLS Policies
-- =========================================================================

-- USERS: Users can view and update their own profiles
CREATE POLICY "Users can view their own profile" ON public.users 
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users 
  FOR UPDATE USING (auth.uid() = id);

-- Trigger to automatically create a profile in public.users when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, phone_number)
  VALUES (new.id, new.phone);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if it exists to allow re-running this script
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- DRAWS: Anyone authenticated can view draws, only admins can insert/update (assumed via dashboard)
CREATE POLICY "Anyone can view draws" ON public.draws 
  FOR SELECT TO authenticated USING (true);

-- TICKETS: Users can insert their own tickets and view their own tickets
CREATE POLICY "Users can view their own tickets" ON public.tickets 
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own tickets" ON public.tickets 
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- PAYMENTS: Users can view and insert their own payments
CREATE POLICY "Users can view their own payments" ON public.payments 
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own payments" ON public.payments 
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- =========================================================================
-- 4. Initial Mock Data (Optional - useful for testing the UI instantly)
-- =========================================================================

INSERT INTO public.draws (id, name, draw_date, ticket_price)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Dear Morning', NOW() + interval '1 day', 100.00),
  ('22222222-2222-2222-2222-222222222222', 'Dear Evening', NOW() + interval '12 hours', 200.00)
ON CONFLICT (id) DO NOTHING;
