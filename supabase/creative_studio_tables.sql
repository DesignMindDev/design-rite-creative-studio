-- Creative Studio Database Schema
-- AI-powered content generation platform for security marketing

-- =============================================================================
-- TABLE: creative_projects
-- Stores creative content generation projects
-- =============================================================================
CREATE TABLE IF NOT EXISTS creative_projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  service_name TEXT DEFAULT 'creative-studio',

  -- Project metadata
  name TEXT NOT NULL,
  description TEXT,
  project_type TEXT NOT NULL, -- 'blog-post', 'case-study', 'product-description', 'email-campaign', etc.
  status TEXT DEFAULT 'draft', -- 'draft', 'in-progress', 'review', 'published', 'archived'

  -- Content settings
  target_audience TEXT,
  tone TEXT, -- 'professional', 'casual', 'technical', 'persuasive', etc.
  industry TEXT, -- 'security', 'low-voltage', 'access-control', etc.

  -- AI assistant tracking
  thread_id TEXT, -- OpenAI thread ID for conversation
  assistant_id TEXT, -- OpenAI assistant ID used

  -- Project data
  content JSONB, -- Generated content sections
  assets JSONB, -- Array of asset URLs (images, videos, etc.)
  metadata JSONB, -- Additional project-specific metadata

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  published_at TIMESTAMPTZ
);

-- Index for fast user queries
CREATE INDEX IF NOT EXISTS idx_creative_projects_user_id ON creative_projects(user_id);
CREATE INDEX IF NOT EXISTS idx_creative_projects_status ON creative_projects(status);
CREATE INDEX IF NOT EXISTS idx_creative_projects_type ON creative_projects(project_type);
CREATE INDEX IF NOT EXISTS idx_creative_projects_service ON creative_projects(service_name);

-- =============================================================================
-- TABLE: creative_assets
-- Stores uploaded and generated assets (images, videos, documents)
-- =============================================================================
CREATE TABLE IF NOT EXISTS creative_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES creative_projects(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  service_name TEXT DEFAULT 'creative-studio',

  -- Asset metadata
  asset_type TEXT NOT NULL, -- 'image', 'video', 'document', 'audio'
  file_name TEXT NOT NULL,
  file_size INTEGER, -- bytes
  mime_type TEXT,

  -- Storage location
  storage_bucket TEXT DEFAULT 'creative-assets',
  storage_path TEXT NOT NULL,
  public_url TEXT,

  -- AI-generated metadata
  ai_description TEXT, -- AI-generated description of the asset
  ai_tags JSONB, -- Array of AI-detected tags

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_creative_assets_project_id ON creative_assets(project_id);
CREATE INDEX IF NOT EXISTS idx_creative_assets_user_id ON creative_assets(user_id);
CREATE INDEX IF NOT EXISTS idx_creative_assets_type ON creative_assets(asset_type);

-- =============================================================================
-- TABLE: creative_templates
-- Reusable content templates for different content types
-- =============================================================================
CREATE TABLE IF NOT EXISTS creative_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- NULL for global templates
  service_name TEXT DEFAULT 'creative-studio',

  -- Template metadata
  name TEXT NOT NULL,
  description TEXT,
  template_type TEXT NOT NULL, -- 'blog-post', 'case-study', etc.
  industry TEXT, -- Target industry

  -- Template structure
  sections JSONB NOT NULL, -- Array of content sections with prompts
  default_tone TEXT,
  default_audience TEXT,

  -- Template settings
  is_public BOOLEAN DEFAULT FALSE, -- Available to all users
  is_system BOOLEAN DEFAULT FALSE, -- System-provided template

  -- Usage tracking
  usage_count INTEGER DEFAULT 0,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_creative_templates_user_id ON creative_templates(user_id);
CREATE INDEX IF NOT EXISTS idx_creative_templates_type ON creative_templates(template_type);
CREATE INDEX IF NOT EXISTS idx_creative_templates_public ON creative_templates(is_public) WHERE is_public = true;

-- =============================================================================
-- TABLE: creative_generations
-- Tracks individual AI content generation requests
-- =============================================================================
CREATE TABLE IF NOT EXISTS creative_generations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES creative_projects(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  service_name TEXT DEFAULT 'creative-studio',

  -- Generation details
  generation_type TEXT NOT NULL, -- 'content', 'image', 'optimization', etc.
  prompt TEXT NOT NULL,
  model TEXT, -- 'gpt-4', 'gpt-3.5-turbo', 'dall-e-3', etc.

  -- Request/response
  request_params JSONB,
  response_content TEXT,
  response_metadata JSONB,

  -- Status and error tracking
  status TEXT DEFAULT 'pending', -- 'pending', 'completed', 'failed'
  error_message TEXT,

  -- Cost tracking
  tokens_used INTEGER,
  estimated_cost DECIMAL(10, 6),

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_creative_generations_project_id ON creative_generations(project_id);
CREATE INDEX IF NOT EXISTS idx_creative_generations_user_id ON creative_generations(user_id);
CREATE INDEX IF NOT EXISTS idx_creative_generations_status ON creative_generations(status);
CREATE INDEX IF NOT EXISTS idx_creative_generations_created ON creative_generations(created_at DESC);

-- =============================================================================
-- STORAGE BUCKET: creative-assets
-- Public bucket for uploaded and generated creative assets
-- =============================================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'creative-assets',
  'creative-assets',
  true, -- Public bucket for easy sharing
  10485760, -- 10MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'video/mp4', 'application/pdf']
)
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================

-- Enable RLS on all tables
ALTER TABLE creative_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE creative_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE creative_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE creative_generations ENABLE ROW LEVEL SECURITY;

-- creative_projects policies
CREATE POLICY "Users can view their own projects"
  ON creative_projects FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own projects"
  ON creative_projects FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own projects"
  ON creative_projects FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own projects"
  ON creative_projects FOR DELETE
  USING (auth.uid() = user_id);

-- creative_assets policies
CREATE POLICY "Users can view their own assets"
  ON creative_assets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own assets"
  ON creative_assets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own assets"
  ON creative_assets FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own assets"
  ON creative_assets FOR DELETE
  USING (auth.uid() = user_id);

-- creative_templates policies
CREATE POLICY "Users can view public and their own templates"
  ON creative_templates FOR SELECT
  USING (is_public = true OR auth.uid() = user_id);

CREATE POLICY "Users can create their own templates"
  ON creative_templates FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own templates"
  ON creative_templates FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own templates"
  ON creative_templates FOR DELETE
  USING (auth.uid() = user_id);

-- creative_generations policies
CREATE POLICY "Users can view their own generations"
  ON creative_generations FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own generations"
  ON creative_generations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- =============================================================================
-- STORAGE POLICIES
-- =============================================================================

-- Allow authenticated users to upload assets
CREATE POLICY "Users can upload assets"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'creative-assets');

-- Allow users to view all public assets
CREATE POLICY "Anyone can view public assets"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'creative-assets');

-- Allow users to update their own assets
CREATE POLICY "Users can update their own assets"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'creative-assets' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to delete their own assets
CREATE POLICY "Users can delete their own assets"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'creative-assets' AND auth.uid()::text = (storage.foldername(name))[1]);

-- =============================================================================
-- FUNCTIONS
-- =============================================================================

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to automatically update updated_at
CREATE TRIGGER update_creative_projects_updated_at
  BEFORE UPDATE ON creative_projects
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_creative_assets_updated_at
  BEFORE UPDATE ON creative_assets
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_creative_templates_updated_at
  BEFORE UPDATE ON creative_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- SAMPLE DATA
-- =============================================================================

-- Insert some system templates for common use cases
INSERT INTO creative_templates (name, description, template_type, industry, sections, default_tone, default_audience, is_public, is_system)
VALUES
  (
    'Security Blog Post',
    'Standard template for security industry blog posts',
    'blog-post',
    'security',
    '[
      {"name": "Introduction", "prompt": "Write an engaging introduction about {topic}"},
      {"name": "Problem Statement", "prompt": "Describe the security challenges related to {topic}"},
      {"name": "Solution", "prompt": "Explain how {product/service} addresses these challenges"},
      {"name": "Benefits", "prompt": "List key benefits and ROI"},
      {"name": "Call to Action", "prompt": "Write a compelling CTA"}
    ]'::jsonb,
    'professional',
    'security-decision-makers',
    true,
    true
  ),
  (
    'Case Study',
    'Customer success story template',
    'case-study',
    'security',
    '[
      {"name": "Customer Overview", "prompt": "Introduce the customer and their industry"},
      {"name": "Challenge", "prompt": "Describe the security challenges they faced"},
      {"name": "Solution", "prompt": "Explain the solution implemented"},
      {"name": "Results", "prompt": "Quantify the results and improvements"},
      {"name": "Testimonial", "prompt": "Include a customer quote"}
    ]'::jsonb,
    'professional',
    'prospects',
    true,
    true
  ),
  (
    'Product Description',
    'Template for security product descriptions',
    'product-description',
    'security',
    '[
      {"name": "Overview", "prompt": "Brief product overview and value proposition"},
      {"name": "Key Features", "prompt": "List main features and capabilities"},
      {"name": "Technical Specs", "prompt": "Include technical specifications"},
      {"name": "Applications", "prompt": "Describe ideal use cases"},
      {"name": "Why Choose This", "prompt": "Differentiation from competitors"}
    ]'::jsonb,
    'technical',
    'technical-buyers',
    true,
    true
  )
ON CONFLICT DO NOTHING;

-- =============================================================================
-- COMPLETION MESSAGE
-- =============================================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Creative Studio database schema created successfully!';
  RAISE NOTICE 'Tables: creative_projects, creative_assets, creative_templates, creative_generations';
  RAISE NOTICE 'Storage bucket: creative-assets (public, 10MB limit)';
  RAISE NOTICE 'Sample templates: 3 system templates added';
END $$;
