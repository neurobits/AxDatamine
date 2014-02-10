'use strict';

var mongoose = require('mongoose'),
    Report = mongoose.model('Report'),
    passport = require('passport');
    
/**
 * Thing Schema
 */
var ThingSchema = new Schema({
  name: String,
  info: String,
  awesomeness: Number
});

/**
 * Validations
 */
ThingSchema.path('awesomeness').validate(function (num) {
  return num >= 1 && num <= 10;
}, 'Awesomeness must be between 1 and 10');



/**
 *  Get profile of specified user
 */
exports.show = function (req, res, next) {
  var reportId = req.params.id;

  report.findById(reportId, function (err, user) {
    if (err) return next(new Error('Failed to load Report'));
  
    if (user) {
      res.send({ reportParameters: report.reportParameters });
    } else {
      res.send(404, 'REPORT_NOT_FOUND');
    }
  });
};

exports.list = function (req, res, next) {
  var reportId = req.params.id;

  User.find(reportId, function (err, user) {
    if (err) return next(new Error('Failed to load Reports'));
  
    if (report) {
      res.send({ reportParameters: report.reportParameters });
    } else {
      res.send(404, 'REPORTS_NOT_FOUND');
    }
  });

mongoose.model('Thing', ThingSchema);
