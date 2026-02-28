/**
 * Supabase Client Configuration
 * 
 * Initializes and exports Supabase client with service role key
 * for server-side operations requiring elevated permissions.
 */

const { createClient } = require('@supabase/supabase-js');

// Validate required environment variables
if (!process.env.SUPABASE_URL) {
  throw new Error('SUPABASE_URL environment variable is required');
}

if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error('SUPABASE_SERVICE_ROLE_KEY environment variable is required');
}

/**
 * Supabase client with service role key
 * Used for server-side operations that bypass RLS
 */
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    },
    db: {
      schema: 'public'
    }
  }
);

/**
 * Test database connection
 * @returns {Promise<boolean>} Connection status
 */
const testConnection = async () => {
  try {
    const { error } = await supabase.from('hospitals').select('count', { count: 'exact', head: true });
    if (error) throw error;
    console.log('✓ Supabase connection established');
    return true;
  } catch (error) {
    console.error('✗ Supabase connection failed:', error.message);
    return false;
  }
};

module.exports = {
  supabase,
  testConnection
};
