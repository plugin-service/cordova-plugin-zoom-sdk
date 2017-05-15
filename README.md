ZoOm SDK Cordova Plugin
-----------------------
This plugin provides easy access to the ZoOm login SDK from a Cordova app using the Android or iOS platform.  Sample code available [here](https://github.com/facetec/cordova-example-zoom-sdk).

Installation
---------------
From an existing Cordova project, run `cordova plugin add https://github.com/facetec/cordova-plugin-zoom-sdk`

If you don't have a Cordova project or don't know how to run one, please see the [Cordova](https://cordova.apache.org/#getstarted) documentation.

For Android, make sure that the manifest file at "platforms/android/AndroidManifest.xml" has a *minSdkVersion* of at least 18

Initializing the SDK
--------------------
You must first initialize the SDK with your app token before you can enroll or login using the SDK. If you do not have an app token, register for [developer access](https://dev.zoomlogin.com/).

```javascript
    ZoomAuthentication.initialize(appToken, onSuccess, onFailure);
```

Enrolling a User
----------------
```javascript
    var userId = "A unique user id";
    var encryptionSecret = "Some secret string";

    function onEnrollComplete(result) {
        if (result.successful) {
            alert('Success!');
        }
        else {
            alert(result.status);
        }
    }

    ZoomAuthentication.enroll(userId, encryptionSecret, onEnrollComplete, onError);
```

The encryption secret can be any string the developer desires.  It will be used as part of the encryption of the user's data and the exact string must always be provided during authentication.

Authenticating a User
---------------------
```javascript
    var userId = "A previously enrolled user id";
    var encryptionSecret = "Some secret string";

    function onAuthComplete(result) {
        if (result.successful) {
            alert('Success!');
        }
        else {
            alert(result.status);
        }
    }

    ZoomAuthentication.authenticate(userId, encryptionSecret, onAuthComplete, onError);
```
