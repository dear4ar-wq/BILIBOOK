-- =========================================================================
-- BIKIPRIZE - SUPABASE SQL SCHEMA AND STORAGE SETUP
-- =========================================================================

-- 1. Create Tables

-- PRIZE TICKETS Table
CREATE TABLE IF NOT EXISTS public.prize_tickets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  ticket_id_display TEXT NOT NULL UNIQUE, -- Auto-generated display ID (e.g., BK-XXXXXX)
  image_url TEXT NOT NULL,
  sem_count INTEGER NOT NULL CHECK (sem_count IN (5, 10, 30, 50, 100, 200)),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'verifying', 'approved', 'rejected')),
  prize_amount NUMERIC(10, 2) DEFAULT 0.0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- PRIZE PAYMENTS Table (For claims)
CREATE TABLE IF NOT EXISTS public.prize_payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  ticket_id UUID NOT NULL REFERENCES public.prize_tickets(id) ON DELETE CASCADE,
  amount NUMERIC(10, 2) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'success', 'failed')),
  razorpay_payment_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- PRIZE NOTIFICATIONS Table
CREATE TABLE IF NOT EXISTS public.prize_notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  ticket_id UUID NOT NULL REFERENCES public.prize_tickets(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.prize_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prize_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prize_notifications ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS Policies

-- PRIZE NOTIFICATIONS
CREATE POLICY "Users can view their own prize notifications" ON public.prize_notifications 
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

-- PRIZE TICKETS
CREATE POLICY "Users can view their own prize tickets" ON public.prize_tickets 
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own prize tickets" ON public.prize_tickets 
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- PRIZE PAYMENTS
CREATE POLICY "Users can view their own prize payments" ON public.prize_payments 
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own prize payments" ON public.prize_payments 
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- 4. Storage Setup (Bucket names must be created in Dashboard usually, but policies can be added)
-- Policy for prize-tickets bucket
-- Note: These policies assume a bucket named 'prize-tickets' exists.

/* 
-- Run these in the Supabase Dashboard if you haven't created the bucket yet:
-- insert into storage.buckets (id, name, public) values ('prize-tickets', 'prize-tickets', false);
*/

CREATE POLICY "Users can upload their own ticket images"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'prize-tickets' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Users can view their own ticket images"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'prize-tickets' AND (storage.foldername(name))[1] = auth.uid()::text);

-- 5. Auto-Delete Function (24 Hours)
-- This function deletes tickets and their associated storage objects (if using storage extension)
-- that are older than 24 hours.

CREATE OR REPLACE FUNCTION public.delete_old_prize_tickets()
RETURNS void AS $$
BEGIN
  -- Delete records from prize_tickets older than 24 hours
  -- Associated payments will be deleted via ON DELETE CASCADE
  DELETE FROM public.prize_tickets
  WHERE created_at < NOW() - INTERVAL '24 hours';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Note: To automate this, you'd typically use pg_cron if enabled on your Supabase project:
-- SELECT cron.schedule('delete-old-tickets-every-hour', '0 * * * *', 'SELECT public.delete_old_prize_tickets()');
