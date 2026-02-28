/**
 * Config Index
 * 
 * Central export for all configuration modules.
 */

const { supabase, testConnection } = require('./supabase');
const constants = require('./constants');

module.exports = {
  supabase,
  testConnection,
  ...constants
};
