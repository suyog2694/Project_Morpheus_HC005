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
const dispatchService = require('./dispatchService');

module.exports = {
  emergencyService,
  ambulanceService,
  hospitalMatcher,
  stabilizationService,
  resourceService,
  dispatchService
};
