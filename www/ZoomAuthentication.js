var exec = require('cordova/exec');

exports.initialize = function(appToken, success, error) {
  exec(success, error, "ZoomAuthentication", "initialize", [appToken]);
};

exports.enroll = function(userId, encryptionSecret, success, error) {
  exec(success, error, "ZoomAuthentication", "enroll", [userId, encryptionSecret]);
}

exports.authenticate = function(userId, encryptionSecret, success, error) {
  exec(success, error, "ZoomAuthentication", "authenticate", [userId, encryptionSecret]);
}

exports.verify = function(success, error) {
  exec(success, error, "ZoomAuthentication", "verify", []);
}

exports.getVersion = function(success, error) {
  exec(success, error, "ZoomAuthentication", "getVersion", []);
};

exports.getSdkStatus = function(success, error) {
  exec(success, error, "ZoomAuthentication", "getSdkStatus", []);
}

exports.getUserEnrollmentStatus = function(userId, success, error) {
  exec(success, error, "ZoomAuthentication", "getUserEnrollmentStatus", [userId]);
}

exports.isUserEnrolled = function(userId, success, error) {
  function onSuccess(status) {
    if (success) {
      success(status == "Enrolled");
    }
  }
  exec(onSuccess, error, "ZoomAuthentication", "getUserEnrollmentStatus", [userId]); 
}