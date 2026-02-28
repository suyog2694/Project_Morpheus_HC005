/**
 * Services Index
 * 
 * Central export point for all service modules.
 */

const emergencyService = require('./emergencyService');
const ambulanceService = require('./ambulanceService');
const hospitalMatcher = require('./hospitalMatcher');
const stabilizationService = require('./stabilizationService');
const resourceService = require('./resourceService');

module.exports = {
  emergencyService,
  ambulanceService,
  hospitalMatcher,
  stabilizationService,
  resourceService
};
