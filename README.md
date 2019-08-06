**Limited Support Notice**
--------------------------
This plugin, bindings, and sample code are meant for example purposes only.  This example will no longer run out of the box from this Github project.  This project is intended to be reference code for how you can integrate ZoOm as a native plugin in the Cordova/Ionic/PhoneGap ecosystem.  This example is based on an earlier version of ZoOm (6.5.0) from mid-2018 that is no longer support and the APIs have changed (please see https://dev.zoomlogin.com/zoomsdk/#/ for latest version information).

If you are familiar with Cordova/Ionic/PhoneGap and Native Modules in these ecosystems, this plugin and the sample provided is 90% of the work to get ZoOm working in your Cordova/Ionic/PhoneGap app.  The remaining work is in updating the bindings to our latest released Native iOS and Android libraries (7.0.0)+, which can be downloaded here - https://dev.zoomlogin.com/zoomsdk/#/downloads.

Hopefully this is enough to get you going!

If you have any more technical questions please feel free to contact us at support@zoomlogin.com
------------------------------
**End Limited Support Notice**

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
