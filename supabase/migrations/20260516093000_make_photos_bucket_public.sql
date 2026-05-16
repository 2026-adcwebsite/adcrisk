-- Make form-photos bucket public so photos display without signed URL expiry
UPDATE storage.buckets
SET public = true
WHERE id = 'form-photos';

-- Ensure RLS policies allow public read on form-photos
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'Public read form-photos'
  ) THEN
    CREATE POLICY "Public read form-photos"
      ON storage.objects FOR SELECT
      USING (bucket_id = 'form-photos');
  END IF;
END $$;
