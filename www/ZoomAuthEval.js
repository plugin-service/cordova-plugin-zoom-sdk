  var exec = require('cordova/exec');

  exports.initialize = function(appToken, success, error) {
    exec(success, error, "ZoomAuthentication", "initialize", [appToken]);
  };
  //Above function for initializing the SDK. A valid appToken should be passed
  //Output similar to getSdkStatus function below

  exports.enroll = function(userId, success, error) {
    exec(success, error, "ZoomAuthentication", "enroll", [userId]);
  }
  //Above function will only work in full version as this require server side integration
  //Above function is for enrolling a new user. Unique userId should be passed

  exports.authenticate = function(userId, success, error) {
    exec(success, error, "ZoomAuthentication", "authenticate", [userId]);
  }
  //Above function will only work in full version as this require server side integration
  //Above function is for authenticating an already enrolled user. userId of the user should be passed

  exports.verify = function(success, error) {
    exec(success, error, "ZoomAuthentication", "verify", []);
  }
  //Above function is for doing liveness check on the device and the server
  //Output could be one of the following
    //"Liveness Check Passed"
    //"The facemap did not exhibit liveness"
    //"The session could not be processed due to not enough quality frames provided during the session capture."
    //"You must pass a valid facemap parameter",
    //"Empty string not valid for parameter facemap",
    //"The request is missing the sessionId parameter. The sessionId parameter is required and can be obtained from the output of the ZoOm iOS/Android/Web SDK. For more information, please visit https://dev.zoomlogin.com/zoomsdk/#/webservice-guide",
    //"sessionId must be at least 10 characters",
    //"Source data length is < 20",

  exports.getVersion = function(success, error) {
    exec(success, error, "ZoomAuthentication", "getVersion", []);
  };
  //Above function is for checking the SDK version

  exports.getSdkStatus = function(success, error) {
    exec(success, error, "ZoomAuthentication", "getSdkStatus", []);
  }
  //Above function is for checking the status of the SDK
  //Output could be one of the below
    //"NeverInitialized";
    //"Initialized";
    //"InvalidToken";
    //"VersionDeprecated";
    //"NetworkIssues";
    //"OfflineSessionsExceeded";
    //"DeviceNotSupported";
    //"DeviceInLandscapeMode";
    //"DeviceInReversePortraitMode";
    //"DeviceLockedOut";
    //"LicenseExpiredOrInvalid";
    //"UnknownStatus";

  exports.getUserEnrollmentStatus = function(userId, success, error) {
    exec(success, error, "ZoomAuthentication", "getUserEnrollmentStatus", [userId]);
  }
  //Above function will only work in full version as this require server side integration
  //Above function is for checking the enrollment status of an user. userId of the user should be passed.
  //Output could be "Enrolled"  or "Not Enrolled"

  exports.isUserEnrolled = function(userId, success, error) {
    function onSuccess(status) {
      if (success) {
        success(status == "Enrolled");
      }
    }
    exec(onSuccess, error, "ZoomAuthentication", "getUserEnrollmentStatus", [userId]);
  }
  //Above function is for checking if a user is already enrolled or not. userId of the user should be passed.
  //Output is true or false

  exports.setPublicKey = function(publicKey, success, error) {
    exec(success, error, "ZoomAuthentication", "setPublicKey", [publicKey]);
  }
  //Above function is for setting the public key to be used by the SDK.
  //For development mode public key need not be setup
  //For production mode public key need to be setup before calling initialize
  //Please check with FaceTec support team to enable production mode as well as to register the public key.

  exports.setServerUrl = function(serverUrl, success, error) {
    exec(success, error, "ZoomAuthentication", "setServerUrl", [serverUrl]);
  }
  //Above function is for setting the zoom server url if it is different than the default one

  exports.setBrandingLogo = function(brandingLogo, success, error) {
    exec(success, error, "ZoomAuthentication", "setBrandingLogo", [brandingLogo]);
  }
  //Above function is for setting custom logo in the zoom screens

  exports.setMainForeGroundColors = function(foreGroundColors, success, error) {
    exec(success, error, "ZoomAuthentication", "setForeGroundColors", [foreGroundColors]);
  }
  //Above function is for setting the custom fore ground color of zoom main screens

  exports.setMainBackGroundColors = function(backGroundColors, success, error) {
    exec(success, error, "ZoomAuthentication", "setBackGroundColors", [backGroundColors]);
  }
  //Above function is for setting the custom back ground color of zoom main screens
