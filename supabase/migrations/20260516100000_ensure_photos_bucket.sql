-- Ensure form-photos bucket exists and is public
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'form-photos',
  'form-photos',
  true,
  10485760,
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/heic', 'image/heif']
)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Drop old policies if they exist to avoid conflicts
DO $$
BEGIN
  DROP POLICY IF EXISTS "Public read form-photos" ON storage.objects;
  DROP POLICY IF EXISTS "Authenticated upload form-photos" ON storage.objects;
  DROP POLICY IF EXISTS "Owner delete form-photos" ON storage.objects;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Allow anyone to read photos (public bucket)
CREATE POLICY "Public read form-photos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'form-photos');

-- Allow authenticated users to upload photos
CREATE POLICY "Authenticated upload form-photos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'form-photos');

-- Allow users to delete their own photos
CREATE POLICY "Owner delete form-photos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'form-photos' AND (storage.foldername(name))[1] = auth.uid()::text);
