/**
 * Controllers Index
 * 
 * Central export point for all controllers.
 */

const patientController = require('./patientController');
const ambulanceController = require('./ambulanceController');
const hospitalController = require('./hospitalController');

module.exports = {
  patientController,
  ambulanceController,
  hospitalController
};
