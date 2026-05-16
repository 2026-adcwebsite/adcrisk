-- Fix worker data isolation: workers must only see their own form submissions
-- Timestamp: 20260516095000

-- Drop existing form_submissions SELECT policies
DROP POLICY IF EXISTS "workers_read_own_submissions" ON public.form_submissions;
DROP POLICY IF EXISTS "managers_read_all_submissions" ON public.form_submissions;

-- Recreate: workers can only read rows where submitted_by = their own auth.uid()
CREATE POLICY "workers_read_own_submissions"
ON public.form_submissions
FOR SELECT
TO authenticated
USING (submitted_by = auth.uid());

-- Recreate: admins/managers/supervisors can read ALL submissions
-- This policy only applies when the user has one of those roles
CREATE POLICY "managers_read_all_submissions"
ON public.form_submissions
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE id = auth.uid()
    AND role IN ('admin', 'manager', 'supervisor')
  )
);
