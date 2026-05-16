-- ADC Risk Assessment App - Full Schema Migration
-- Timestamp: 20260516090000

-- ─── 1. Types ─────────────────────────────────────────────────────────────────
DROP TYPE IF EXISTS public.user_role CASCADE;
CREATE TYPE public.user_role AS ENUM ('admin', 'manager', 'supervisor', 'worker');

-- ─── 2. Core Tables ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL DEFAULT '',
    role public.user_role DEFAULT 'worker'::public.user_role,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.form_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submitted_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    submitter_name TEXT NOT NULL DEFAULT '',
    work_order TEXT,
    submitted_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    work_types JSONB DEFAULT '{}',
    activities JSONB DEFAULT '{}',
    ppe_checklist JSONB DEFAULT '{}',
    employees JSONB DEFAULT '[]',
    suspension_reason TEXT,
    photo_urls JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ─── 3. Indexes ───────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX IF NOT EXISTS idx_form_submissions_submitted_by ON public.form_submissions(submitted_by);
CREATE INDEX IF NOT EXISTS idx_form_submissions_submitted_at ON public.form_submissions(submitted_at DESC);

-- ─── 4. Functions ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'role', 'worker')::public.user_role
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.is_admin_or_manager()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE id = auth.uid()
    AND role IN ('admin', 'manager', 'supervisor')
)
$$;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE id = auth.uid()
    AND role = 'admin'
)
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- ─── 5. Enable RLS ────────────────────────────────────────────────────────────
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.form_submissions ENABLE ROW LEVEL SECURITY;

-- ─── 6. RLS Policies ─────────────────────────────────────────────────────────

-- user_profiles: own row access
DROP POLICY IF EXISTS "users_manage_own_profile" ON public.user_profiles;
CREATE POLICY "users_manage_own_profile"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- user_profiles: admins can read all
DROP POLICY IF EXISTS "admins_read_all_profiles" ON public.user_profiles;
CREATE POLICY "admins_read_all_profiles"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (public.is_admin_or_manager());

-- user_profiles: admins can insert new users
DROP POLICY IF EXISTS "admins_insert_profiles" ON public.user_profiles;
CREATE POLICY "admins_insert_profiles"
ON public.user_profiles
FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

-- user_profiles: admins can update any profile
DROP POLICY IF EXISTS "admins_update_profiles" ON public.user_profiles;
CREATE POLICY "admins_update_profiles"
ON public.user_profiles
FOR UPDATE
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- form_submissions: workers can insert own
DROP POLICY IF EXISTS "workers_insert_own_submissions" ON public.form_submissions;
CREATE POLICY "workers_insert_own_submissions"
ON public.form_submissions
FOR INSERT
TO authenticated
WITH CHECK (submitted_by = auth.uid());

-- form_submissions: workers can read own
DROP POLICY IF EXISTS "workers_read_own_submissions" ON public.form_submissions;
CREATE POLICY "workers_read_own_submissions"
ON public.form_submissions
FOR SELECT
TO authenticated
USING (submitted_by = auth.uid());

-- form_submissions: managers/supervisors/admins can read all
DROP POLICY IF EXISTS "managers_read_all_submissions" ON public.form_submissions;
CREATE POLICY "managers_read_all_submissions"
ON public.form_submissions
FOR SELECT
TO authenticated
USING (public.is_admin_or_manager());

-- ─── 7. Triggers ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- ─── 8. Mock Data ─────────────────────────────────────────────────────────────
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    manager_uuid UUID := gen_random_uuid();
    worker_uuid UUID := gen_random_uuid();
BEGIN
    -- Admin user
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@adc-al.com', crypt('ADC@2026', gen_salt('bf', 10)), now(), now(), now(),
         jsonb_build_object('full_name', 'Admin ADC', 'role', 'admin'),
         jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (manager_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'manager@adc-al.com', crypt('ADC@2026', gen_salt('bf', 10)), now(), now(), now(),
         jsonb_build_object('full_name', 'Artan Hoxha', 'role', 'manager'),
         jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (worker_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'arta.hoxha@adc-al.com', crypt('ADC@2026', gen_salt('bf', 10)), now(), now(), now(),
         jsonb_build_object('full_name', 'Arta Hoxha', 'role', 'worker'),
         jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null)
    ON CONFLICT (id) DO NOTHING;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data insertion failed: %', SQLERRM;
END $$;
