
ZoOm SDK Cordova Plugin
-----------------------

This plugin provides easy access to the ZoOm SDK from a Cordova app using the Android or iOS platform. The plugin provided by FaceTec, creators of the ZoOm SDK, no longer support their Cordova plugin starting at ZoOm 6.5.0.  This plugin modifies that plugin to get it to work with the latest version of the Zoom SDK.  This plugin is created by SnapCommute Labs Pvt. Ltd.  This plugin contains limited functionality.  For full version of the plugin please send an email request to plugins@snapcommute.com. The full version has functionalities for enrollment and authentication as well as full customization options available through ZoOm SDK.

Installation
---------------
From an existing Cordova project, run `cordova plugin add https://github.com/plugin-service/cordova-plugin-zoom-sdk`

If you don't have a Cordova project or don't know how to run one, please see the [Cordova](https://cordova.apache.org/#getstarted) documentation.

File Copy and Modifications:
-
Since the Zoom SDK files are large, it is not included in the github. Please visit [ZoomLogin Developer Website](https://dev.zoomlogin.com) and download the sdk files and copy the relevant file to the root folder of this plugin.

For Android, there will be a .aar file inside the downloaded zip file (like zoom-authentication-hybrid-<version #>.aar), which has to be copied to the root folder. For iOS, there will be a folder named ZoomAuthentication.framework inside ZoomAuthentication-ios-<version #> folder, within the zip file, which has to be zipped and copied to the root folder.

Modification to the hooks file within the hooks folder might be required if the android .aar file is of a different version.

Image files also needs to copied for the latest SDK to work properly. For Android copy the drawable-nodpi folder available in the sample app provided along with the android sdk download. For iOS copy the Assets.xcassets folder available in the sample app provided along with the iOS sdk download. Ensure you delete confilicting images like app icon etc.

Functions available in plugin:
-

Below are details of different functions available in the plugin. Some of them are not enabled in the evaluation version and are included only for demo purpose.

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

    ZoomAuthEval.getUserEnrollmentStatus(userId,onSuccess, onError);

```

User Enrollment Check
---------------------
```javascript

    ZoomAuthEval.isUserEnrolled(userId,onSuccess, onError);
```

Id Check
---------------------
```javascript
  
    ZoomAuthEval.idCheck(onSuccess, onError);
```

Delete Enrollment 
---------------------
```javascript

    ZoomAuthEval.deleteEnrollment(userId,onSuccess, onError);
```

Audit Trail
---------------------
```javascript

    ZoomAuthEval.auditTrail(onSuccess, onError);
```

Set up UI Theme
---------------------
```javascript

    ZoomAuthEval.setDefaultTheme(onSuccess, onError);
    
    ZoomAuthEval.setDarkTheme(onSuccess, onError);
        
    ZoomAuthEval.setMidnightTheme(onSuccess, onError);
            
    ZoomAuthEval.setSunsetTheme(onSuccess, onError);
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
In case you want to enable a custom logo in the screens shown by zoom, you can use the below function to do the same. Replace the custom_zoom_logo.png with your own image (with the same name) in the root folder of the plugin.

```javascript

    ZoomAuthEval.setBrandingLogo(enable, onSuccess, onFailure);

```

Customizing colors
-------------------------
In case you want to change the colors in the screens shown by zoom, you can use the below function to do the same. Pass color in Hex color format.

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

