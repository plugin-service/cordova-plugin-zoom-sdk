**Note from Developer***

Source code files are being uploaded currently. If you need any further information, please contact plugins@snapcommute.com


*******


ZoOm SDK Cordova Plugin
-----------------------
This plugin provides easy access to the Zoom login SDK from a Cordova app using the Android or iOS platform. The plugin provided by FaceTec, vendors of Zoom login SDK, was updated till the SDK version 6.0.5. The vendor stopped updating the plugin for newer SDK versions. The plugin provided by the vendor does not work with the latest SDK versions and hence required updates. This is an evaluation version for the latest Zoom login SDK created by SnapCommute Labs Pvt. Ltd. This version only contains local liveness check and few customizations. For full version of the plugin please send an email request to plugins@snapcommute.com. The full version has server side integration for enrollment and authentication as well as full customization options available through Zoom SDK.

Installation
---------------
From an existing Cordova project, run `cordova plugin add https://github.com/plugin-service/cordova-plugin-zoom-sdk`

If you don't have a Cordova project or don't know how to run one, please see the [Cordova](https://cordova.apache.org/#getstarted) documentation.

Initializing the SDK
--------------------
You must first initialize the SDK with your app token before you can enroll or login using the SDK. If you do not have an app token, register for [developer access](https://dev.zoomlogin.com/).

```javascript
    ZoomAuthEval.initialize(appToken, onSuccess, onFailure);
```

Enrolling a User
----------------
```javascript
    var userId = "A unique user id";

    function onEnrollComplete(result) {
        if (result.successful) {
            alert('Success!');
        }
        else {
            alert(result.status);
        }
    }

    ZoomAuthEval.enroll(userId, onEnrollComplete, onError);
```


Authenticating a User
---------------------
```javascript
    var userId = "A previously enrolled user id";

    function onAuthComplete(result) {
        if (result.successful) {
            alert('Success!');
        }
        else {
            alert(result.status);
        }
    }

    ZoomAuthEval.authenticate(userId, onAuthComplete, onError);
```

Liveness Check
---------------------
```javascript
    function onCheckComplete(result) {
        if (result.successful) {
            alert('Success!');
        }
        else {
            alert(result.status);
        }
    }

    ZoomAuthEval.verify(onCheckComplete, onError);
```

SDK Version Check
---------------------
```javascript

    ZoomAuthEval.getVerision(onSuccess, onFailure);

```

SDK Status Check
---------------------
```javascript

    ZoomAuthEval.getSdkStatus(onSuccess, onFailure);

```

Enrollment Status Check
---------------------
```javascript
    var userId = "A user id";
  
    function onAuthComplete(result) {
        if (result.successful) {
            alert('Success!');
        }
        else {
            alert(result.status);
        }
    }

    ZoomAuthEval.getEnrollmentStatus(userId,onAuthComplete, onError);

```

User Id Check
---------------------
```javascript
   var userId = "A user id";
  
    function onAuthComplete(result) {
        if (result.successful) {
            alert('Success!');
        }
        else {
            alert(result.status);
        }
    }

    ZoomAuthEval.isUserEnrolled(userId,onAuthComplete, onError);
```

Setting up your plubic key
-------------------------------
If you are moving to a production release, Zoom SDK requires you to upload a public SSH key to their server and also use them while initializing the SDK. So, for production app, below function should be called before calling initialize function.

```javascript

    ZoomAuthEval.setPublicKey(publicKey, onSuccess, onFailure);

```

Setting up server url
-------------------------
In case you are using your own zoom server instance, instead of using the FaceTec Managed Rest API server, you can change it using the below function.

```javascript

    ZoomAuthEval.setServerUrl(serverUrl, onSuccess, onFailure);

```

Customizing brand logo
-------------------------
In case you want to change the default logo provided in the screens shown by zoom, you can use the below function to do the same.

```javascript

    ZoomAuthEval.setBrandingLogo(brandingLogo, onSuccess, onFailure);

```

Customizing colors
-------------------------
In case you want to change the colors in the screens shown by zoom, you can use the below function to do the same.

```javascript

    ZoomAuthEval.setMainForeGroundColors(foreGroundColors, onSuccess, onFailure);
    
    ZoomAuthEval.setMainBackGroundColors(backGroundColors, onSuccess, onFailure);

```

Customizing main screen text
-------------------------------
In case you want to change the default text provided in the main screen shown by zoom, you can update the below line in plugin.xml.

```javascript

    <config-file target="res/values/strings.xml" parent="/*">
        <string name="zoom_camera_permission_message_enroll">To get started with ZoOm,\nenable access to your selfie camera.        </string>
    </config-file> 

```
