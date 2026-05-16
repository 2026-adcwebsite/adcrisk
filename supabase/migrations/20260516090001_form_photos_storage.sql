-- Storage bucket for form photos
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'form-photos',
    'form-photos',
    false,
    10485760,
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic']
)
ON CONFLICT (id) DO NOTHING;

-- RLS for storage
DROP POLICY IF EXISTS "authenticated_upload_form_photos" ON storage.objects;
CREATE POLICY "authenticated_upload_form_photos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'form-photos');

DROP POLICY IF EXISTS "authenticated_read_form_photos" ON storage.objects;
CREATE POLICY "authenticated_read_form_photos"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'form-photos');
