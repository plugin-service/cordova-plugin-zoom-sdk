package cordova.plugin.sc.zoomautheval;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.util.Base64;
import android.graphics.Color;
//import android.graphics.Bitmap;

import com.facetec.zoom.sdk.*;
import android.util.Log;
import java.io.IOException;
import android.os.Build;
import java.util.Locale;
//import java.util.ArrayList;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import okhttp3.Response;
import okio.BufferedSink;
import okio.Okio;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.List;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;

enum ZoomServerRequestType {
        Enroll,
        Authenticate,
        LivenessCheck
}

public class ZoomAuthEval extends CordovaPlugin {
private String zoomServerBaseURL = "https://api.zoomauth.com/api/v2/biometrics";
private CallbackContext pendingCallbackContext = null;
private static String TAG = "ZoomAuthentication";
private String licenseKey="";
private String publicKey =
        "-----BEGIN PUBLIC KEY-----\n" +
        "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5PxZ3DLj+zP6T6HFgzzk\n" +
        "M77LdzP3fojBoLasw7EfzvLMnJNUlyRb5m8e5QyyJxI+wRjsALHvFgLzGwxM8ehz\n" +
        "DqqBZed+f4w33GgQXFZOS4AOvyPbALgCYoLehigLAbbCNTkeY5RDcmmSI/sbp+s6\n" +
        "mAiAKKvCdIqe17bltZ/rfEoL3gPKEfLXeN549LTj3XBp0hvG4loQ6eC1E1tRzSkf\n" +
        "GJD4GIVvR+j12gXAaftj3ahfYxioBH7F7HQxzmWkwDyn3bqU54eaiB7f0ftsPpWM\n" +
        "ceUaqkL2DZUvgN0efEJjnWy5y1/Gkq5GGWCROI9XG/SwXJ30BbVUehTbVcD70+ZF\n" +
        "8QIDAQAB\n" +
        "-----END PUBLIC KEY-----";
/*Above is the public key for development phase. A public key as indicated by FaceTec has to be
   generated and used once the app is in production phase
 */
private ZoomServerRequestType latestZoomServerRequestType = ZoomServerRequestType.Authenticate;
private String userId="";
private ZoomCustomization zoomCustomization;
private ZoomManagedSession zoomManagedSession;
private ArrayList<Bitmap> auditTrailImages;

@Override
public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("getVersion")) {
                callbackContext.success(ZoomSDK.version());
        }
        else if (action.equals("getUserEnrollmentStatus")) {
                getUserEnrollmentStatus(args, callbackContext);
        }
        else if (action.equals("getSdkStatus")) {
                callbackContext.success(getSdkStatusString());
        }
        else if (action.equals("initialize")) {
                initialize(args, callbackContext);
        }
        else if (action.equals("enroll")) {
                enroll(args, callbackContext);
        }
        else if (action.equals("authenticate")) {
                authenticate(args, callbackContext);
        }
        else if (action.equals("verify")) {
                verify(args, callbackContext);
        }
        else if (action.equals("setPublicKey")) {
                setPublicKey(args, callbackContext);
        }
        else if (action.equals("setServerUrl")) {
                setServerUrl(args, callbackContext);
        }
        else if (action.equals("setBrandingLogo")) {
                setBrandingLogo(args, callbackContext);
        }
        else if (action.equals("setMainForeGroundColor")) {
                setMainForeGroundColor(args, callbackContext);
        }
        else if (action.equals("setMainBackGroundColor")) {
                setMainBackGroundColor(args, callbackContext);
        }else if (action.equals("idCheck")) {
                idCheck(args, callbackContext);
        }else if (action.equals("deleteEnrollment")) {
                deleteEnrollment(args, callbackContext);
        }else if (action.equals("auditTrail")) {
                auditTrail(args, callbackContext);
        }else if (action.equals("setDefaultTheme")) {
                setDefaultTheme(args, callbackContext);
        }else if (action.equals("setDarkTheme")) {
                setDarkTheme(args, callbackContext);
        }else if (action.equals("setMidnightTheme")) {
                setMidnightTheme(args, callbackContext);
        }else if (action.equals("setSunsetTheme")) {
                setSunsetTheme(args, callbackContext);
        }
        else {
                return false;
        }
        return true;
}
//Above are the functions that will be called by plugin javascript file

private void setPublicKey(JSONArray args, final CallbackContext callbackContext) throws JSONException {

        if(args.length()>0) {
                publicKey=args.getString(0);
                callbackContext.success("Public Key Set");
        }else{
                callbackContext.error("No Public Key Shared");
        }
}
//Above function has to be called from the app once it is in production mode for setting the Public Key

private void setServerUrl(JSONArray args, final CallbackContext callbackContext) throws JSONException {

        if(args.length()>0) {
                zoomServerBaseURL=args.getString(0);
                callbackContext.success("Server url Set");
        }else{
                callbackContext.error("No server url Shared");
        }
}
//Above function can be used to set a different server url if not using the default one

private void setBrandingLogo(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if(args.length()>0 && args.getString(0).equals("true")) {
                final Context context = this.cordova.getActivity();
                String resourceName = "custom_zoom_logo";
                int checkExistence = context.getResources().getIdentifier(resourceName, "drawable", context.getPackageName());
                if ( checkExistence != 0 ) { // the resource exists...
                        ZoomGuidanceImagesCustomization zoomGuidanceImagesCustomization = new ZoomGuidanceImagesCustomization();
                        zoomGuidanceImagesCustomization.introScreenBrandingImage=checkExistence;
                        zoomCustomization.getGuidanceCustomization().setImageCustomization(zoomGuidanceImagesCustomization);
                        callbackContext.success("Custom logo enabled");
                }
                else { // checkExistence == 0  // the resource does NOT exist!!
                        callbackContext.error("No custom logo file available");
                }


        }else{
                callbackContext.error("No custom logo Shared");
        }
}

private void setMainForeGroundColor(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if(args.length()>0) {
                zoomCustomization.getGuidanceCustomization().foregroundColor=Color.parseColor(args.getString(0));
                callbackContext.success("Main Fore Ground Color Set");
        }else{
                callbackContext.error("No main foreground color Shared");
        }
}


private void setMainBackGroundColor(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if(args.length()>0) {
                zoomCustomization.getGuidanceCustomization().backgroundColors=Color.parseColor(args.getString(0));
                callbackContext.success("Main Back Ground Color Set");
        }else{
                callbackContext.error("No main background color Shared");
        }
}


private void initialize(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final String appToken = args.getString(0);
        licenseKey=appToken;
        Log.d(TAG, appToken);
        final Context context = this.cordova.getActivity();
        zoomCustomization = new ZoomCustomization();
        cordova.getThreadPool().execute(new Runnable() {
                        @Override
                        public void run() {
                                ZoomSDK.setFaceMapEncryptionKey(publicKey);
                                ZoomSDK.preload(context);
                                ZoomSDK.initialize(context, appToken, new ZoomSDK.InitializeCallback() {
                                        @Override
                                        public void onCompletion(boolean successful) {
                                                Log.d(TAG, String.valueOf(successful));
                                                if (successful) {
                                                        callbackContext.success();
                                                }
                                                else {
                                                        String status = getSdkStatusString();
                                                        callbackContext.error(status);
                                                }
                                        }
                                });
                        }
                });
}
//Above function initializes the sdk with licenseKey, public key etc.

private void enroll(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        userId = args.getString(0);
        pendingCallbackContext = callbackContext;
        ZoomSDK.setCustomization(zoomCustomization);
        final Context context = this.cordova.getActivity();
        cordova.getThreadPool().execute(new Runnable() {
                        @Override
                        public void run() {
                                zoomManagedSession = new ZoomManagedSession(managedSessionCallback, context, licenseKey, zoomServerBaseURL, ZoomManagedSession.ZoomManagedSessionMode.ENROLL, userId);
                        }
                });
}
//Above function is for enrolling a new user

private void authenticate(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        userId = args.getString(0);
        pendingCallbackContext = callbackContext;
        latestZoomServerRequestType = ZoomServerRequestType.Authenticate;
        ZoomSDK.setCustomization(zoomCustomization);
        final Context context = this.cordova.getActivity();
        cordova.getThreadPool().execute(new Runnable() {
                        @Override
                        public void run() {
                                zoomManagedSession = new ZoomManagedSession(managedSessionCallback, context, licenseKey, zoomServerBaseURL, ZoomManagedSession.ZoomManagedSessionMode.AUTHENTICATE, userId);
                        }
                });
}
//Above function is for authenticating allready enrolled user

private void verify(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        pendingCallbackContext = callbackContext;
        latestZoomServerRequestType = ZoomServerRequestType.LivenessCheck;
        ZoomSDK.setCustomization(zoomCustomization);
        final Context context = this.cordova.getActivity();
        cordova.setActivityResultCallback(this);
        cordova.getThreadPool().execute(new Runnable() {
                        @Override
                        public void run() {
                                zoomManagedSession = new ZoomManagedSession(managedSessionCallback, context, licenseKey, zoomServerBaseURL, ZoomManagedSession.ZoomManagedSessionMode.LIVENESS, userId);
                        }
                });
}
//Above function is for doing a liveness check on the device as well as on the server

private void getUserEnrollmentStatus(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final Context context = this.cordova.getActivity().getApplicationContext();
        final String userId = args.getString(0);
        callbackContext.success("This option available only in full version. Please contact plugins@snapcommute.com for further details");

}
//Above function is for checking if a user is already enrolled or not

ZoomManagedSession.ZoomManagedSessionCallback managedSessionCallback = new ZoomManagedSession.ZoomManagedSessionCallback() {
        @Override
        public void onZoomManagedSessionComplete(final ZoomManagedSession.ZoomManagedSessionStatus status) {
                // Handling of FaceMaps and/or ID Scans for Liveness Checks, Enrollment, Authentication, and Identity Checks
                // has already occurred at this point inside the ZoomManagedSession class.
                // At this point, zoomManagedSessionStatus == .Success if the overall task succeeded.
                // For instance, if this was a Liveness Check and Liveness was proven,
                // or if this is an Identity Check and both Liveness was proven AND the user's face matched their ID Scan.

                // For demonstration purposes, we call a helper function here to parse results and various subcodes to display additional information about what happened.
                // In a production application, the developer already has access to this information via implementing their own version of the ZoomManagedSession class.
                // The ZoomManagedSession class source code is available inside the SDK ZIP, and more information about implementation can be found in the Implementation Guides.

                if(status == ZoomManagedSession.ZoomManagedSessionStatus.UNSUCCESS_CHECK_SUBCODE) {
                        if(zoomManagedSession.getLatestZoomSessionResult() != null && zoomManagedSession.getLatestZoomSessionResult().getStatus() != ZoomSessionStatus.SESSION_COMPLETED_SUCCESSFULLY) {
                                pendingCallbackContext.success(zoomManagedSession.getLatestZoomSessionResult().getStatus().toString());
                        }
                        else {
                                pendingCallbackContext.success(zoomManagedSession.getLatestZoomManagedSessionStatusSubCode().toString());
                        }
                }
                else {
                        pendingCallbackContext.success(status.toString());
                }
                // Update audit trail
                if(zoomManagedSession.getLatestZoomSessionResult().getFaceMetrics() != null) {
                        auditTrailImages = zoomManagedSession.getLatestZoomSessionResult().getFaceMetrics().getAuditTrail();
                }
        }
};

@Override
public void onActivityResult(int requestCode, int resultCode, Intent data) {
        zoomManagedSession.processZoomManagedSessionResult(requestCode, resultCode, data);
}

@NonNull
private String getSdkStatusString() {
        Context context = this.cordova.getActivity();
        ZoomSDKStatus status = ZoomSDK.getStatus(context);
        switch (status) {
        case NEVER_INITIALIZED:
                return "NeverInitialized";
        case INITIALIZED:
                return "Initialized";
        case VERSION_DEPRECATED:
                return "VersionDeprecated";
        case NETWORK_ISSUES:
                return "NetworkIssues";
        case DEVICE_NOT_SUPPORTED:
                return "DeviceNotSupported";
        case DEVICE_IN_LANDSCAPE_MODE:
                return "DeviceInLandscapeMode";
        case DEVICE_IN_REVERSE_PORTRAIT_MODE:
                return "DeviceInReversePortraitMode";
        case DEVICE_LOCKED_OUT:
                return "DeviceLockedOut";
        case LICENSE_EXPIRED_OR_INVALID:
                return "LicenseExpiredOrInvalid";
        }
        return "UnknownStatus";
}
//Above function shows the status of the SDK
private void idCheck(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        callbackContext.success("This option available only in full version. Please contact plugins@snapcommute.com for further details");
}

private void deleteEnrollment(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        callbackContext.success("This option available only in full version. Please contact plugins@snapcommute.com for further details");
}

private void auditTrail(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        JSONObject auditTrailString=new JSONObject();
        if(auditTrailImages.size()>0) {
                for(int i = 0; i < auditTrailImages.size(); i++) {
                        try{
                                auditTrailString.put(String.valueOf(i),this.processPicture(auditTrailImages.get(i),0));
                        } catch (Exception e) {
                                auditTrailString.put(String.valueOf(i),"Error compressing image.");
                        }

                };
                callbackContext.success(auditTrailString);
        }else{
                callbackContext.error("No audit trail available");
        }
        //callbackContext.success("This option available only in full version. Please contact plugins@snapcommute.com for further details");
}

private void setDefaultTheme(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        callbackContext.success("This option available only in full version. Please contact plugins@snapcommute.com for further details");
}

private void setDarkTheme(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        callbackContext.success("This option available only in full version. Please contact plugins@snapcommute.com for further details");
}

private void setMidnightTheme(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        callbackContext.success("This option available only in full version. Please contact plugins@snapcommute.com for further details");
}

private void setSunsetTheme(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        callbackContext.success("This option available only in full version. Please contact plugins@snapcommute.com for further details");
}

public String processPicture(Bitmap bitmap, int encodingType) {
        ByteArrayOutputStream jpeg_data = new ByteArrayOutputStream();
        CompressFormat compressFormat = encodingType == 0 ?
                                        CompressFormat.JPEG :
                                        CompressFormat.PNG;
        String returnValue="";
        try {
                if (bitmap.compress(compressFormat, 50, jpeg_data)) {
                        byte[] code = jpeg_data.toByteArray();
                        byte[] output = Base64.encode(code, Base64.NO_WRAP);
                        String js_out = new String(output);
                        returnValue= js_out;
                        //js_out = null;
                        //output = null;
                        //code = null;
                }
        } catch (Exception e) {
                returnValue = "Error compressing image.";
        }
        jpeg_data = null;
        return returnValue;
}

}

class ZoomManagedSessionFaceMapProcessor implements ZoomFaceMapProcessor {
// Keep track of the identifier of the FaceMap during Enrollment, Authentication, and Identity Check scenarios.
private String enrollmentIdentifier;

// Keep track of last ZoomFaceMapResultCallback so that developers can control the ZoOm UX after asynchronous API calls.
private ZoomFaceMapResultCallback zoomFaceMapResultCallback;

// Keep track of the ZoomManagedSession so that state can be updated as processing progresses.
// Developer Note: Developer can do state tracking via other mechanisms if desired.
private ZoomManagedSession zoomManagedSession;

/*
 * This sample implementation of a ZoomFaceMapProcessor takes the ZoomManagedSession as a reference in order to update state.
 * We need the enrollmentIdentifier optionally depending on the mode.
 */
ZoomManagedSessionFaceMapProcessor(ZoomManagedSession zoomManagedSession, String enrollmentIdentifier) {
        this.zoomManagedSession = zoomManagedSession;
        this.enrollmentIdentifier = enrollmentIdentifier;
}

/*
 * A ZoOm FaceMap Processor defines an interface that the customer implements in order to
 * define the behavior and handling of the ZoOm Session Result (including FaceMap and Audit Images).
 * The ZoOm FaceMap Processor requires the developer to define a “processZoomSessionResultWhileZoomWaits” function.
 * As the name implies, this function is where the developer will handle the ZoOm Session Result
 * (most importantly the FaceMap), while the ZoOm interface continues to stay open (displaying a
 * progress experience that nicely and consistently styled across all platforms and devices)
 * and waits for the result of the processing.
 *
 * In ZoOm 8, the upload progress, animation, and ability to launch directly into the retry
 * experience without needing to start ZoOm (including the camera) from scratch, are all built into the experience.
 *
 * The processZoomSessionResultWhileZoomWaits function gives the developer two objects:
 *
 * 1.  A ZoomSessionResult object -- the developer should be familiar with this object and it has mostly stayed the same since ZoOm 7.  The developer should use this to check the state and invoke behavior that performs processing of the FaceMap on the server.
 * 2.  A ZoomFaceMapResultCallback object -- this object has 4 public functions that can be called:
 *    - succeed() -- this is called after the FaceMap is processed, the scenario succeeds, and the developer would like to invoke the success experience.
 *    - retry() -- this is called after the FaceMap is processed, the scenario requires the user to retry, and the developer would like to invoke the retry experience.
 *    - onProgress(progress: Float) -- this method can be called to control the progress bar progress.  Usually the developer can simply hook this up to the network request progress.
 *    - cancel() -- this method can be called to simply cancel out of the experience.  This is for cases like lack of network connectivity, bad responses from the developer’s own API, or other catastrophic failure scenarios.
 */
public void processZoomSessionResultWhileZoomWaits(ZoomSessionResult zoomSessionResult, final ZoomFaceMapResultCallback zoomFaceMapResultCallback) {
        zoomManagedSession.setLatestZoomSessionResult(zoomSessionResult);
        this.zoomFaceMapResultCallback = zoomFaceMapResultCallback;

        if(zoomSessionResult.getStatus() != ZoomSessionStatus.SESSION_COMPLETED_SUCCESSFULLY) {
                setUnsuccessSubCode(zoomSessionResult);
                zoomFaceMapResultCallback.cancel();
                this.zoomFaceMapResultCallback = null;
                return;
        }

        // Here we set the latest status subcode to Timeout because if this class forgets to call one of the ZoomFaceMapResultCallback functions
        // then as a safety net for users in the wild we implement a catch-all timeout that will cancel the session.
        zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.TIMEOUT;

        // Check the mode and call the appropriate helper function to handle the specific scenario that the application invoked.
        if(zoomManagedSession.getMode() == ZoomManagedSession.ZoomManagedSessionMode.LIVENESS) {
                processLiveness(zoomSessionResult);
        }


}
/*
 * Process the Liveness Check
 *
 * This method of calling the FaceTec Managed API, as well as the string of helper functions and evaluation of the result
 * are fairly prescriptive.  The developer will most likely be completely changing these functions to conform the API calls
 * around the particulars of the developers own webservice/infrastructure/security practices.
 */
private void processLiveness(ZoomSessionResult zoomSessionResult) {
        // Call helper function that calls FaceTec Managed API (or ZoOm Server REST SDK) /liveness endpoint
        // Developer Note: For your production app, you will be calling your own webservice and NOT the FaceTec Managed API or ZoOm Server REST SDK directly.
        callFaceTecManagedAPIForLiveness(zoomSessionResult, new FaceTecManagedAPICallback() {
                        @Override
                        public void onResponse(JSONObject responseJSON) {
                                processLivenessResponseAndGoToNextStep(responseJSON);
                        }
                });
}
/*
 * Handles calling the FaceTec Managed API (or ZoOm Server REST SDK) for Liveness Check.
 * Specific pieces handled:
 * 1.  Vanilla HTTPS request to API to process Liveness Check.
 * 2.  Setting License Key and Headers that are required by FaceTec Managed API
 * 3.  Detecting basic network failure and cancelling out if detected
 * 4.  Updating the progress bar via the ZoomFaceMapResultCallback.onProgress function
 * 5.  Gather the needed data in correct format -- i.e. the FaceMap, Session ID
 * 6.  Hand back response JSON to caller.
 */
private void callFaceTecManagedAPIForLiveness(ZoomSessionResult zoomSessionResult, final FaceTecManagedAPICallback callback)  {
        String zoomFaceMapBase64 = zoomSessionResult.getFaceMetrics().getFaceMapBase64();

        // This generally will not happen, but we still want to check here just in case we get an internal error.
        if(zoomFaceMapBase64.isEmpty()) {
                zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.INTERNAL_UNSUCCESS;
                zoomFaceMapResultCallback.cancel();
                return;
        }

        zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.TIMEOUT;

        JSONObject parameters = new JSONObject();
        try {
                parameters.put("faceMap", zoomFaceMapBase64);
                parameters.put("sessionId", zoomSessionResult.getSessionId());
        }
        catch(JSONException e) {
                e.printStackTrace();
                Log.d("ZoomSDK", "Error setting up JSON for Liveness Check.");
                zoomFaceMapResultCallback.cancel();
        }

        RequestBody requestBody = RequestBody.create(MediaType.parse("application/json; charset=utf-8"), parameters.toString());
        ProgressRequestBody progressRequestBody = new ProgressRequestBody(requestBody,
                                                                          new ProgressRequestBody.Listener() {
                        @Override
                        public void onUploadProgressChanged(long bytesWritten, long totalBytes) {
                                final float uploadProgressPercent = ((float)bytesWritten) / ((float)totalBytes);
                                zoomFaceMapResultCallback.uploadProgress(uploadProgressPercent);
                        }
                });

        // Do the network call and handle result
        okhttp3.Request request = new okhttp3.Request.Builder()
                                  .header("Content-Type", "application/json")
                                  .header("X-Device-License-Key", zoomManagedSession.deviceLicenseKeyIdentifier)
                                  .header("User-Agent", ZoomSDK.createZoomAPIUserAgentString(zoomSessionResult.getSessionId()))
                                  .url(zoomManagedSession.zoomServerBaseURL + "/liveness")
                                  .post(progressRequestBody)
                                  .build();

        zoomManagedSession.latestFaceTecAPIResponseString = "";

        ZoomManagedSession.getApiClient().newCall(request).enqueue(new Callback() {
                        @Override
                        public void onFailure(Call call, IOException e) {
                                e.printStackTrace();
                                Log.d("ZoomSDK", "Error during HTTPS call.");
                                zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.NETWORK_ERROR;
                                zoomFaceMapResultCallback.cancel();
                        }

                        @Override
                        public void onResponse(Call call, okhttp3.Response response) throws IOException {
                                String responseString = response.body().string();
                                response.body().close();
                                try {
                                        JSONObject responseJSON = new JSONObject(responseString);
                                        callback.onResponse(responseJSON);
                                }
                                catch(JSONException e) {
                                        e.printStackTrace();
                                        Log.d("ZoomSDK", "Error while parsing JSON result.");
                                        zoomFaceMapResultCallback.cancel();
                                }
                        }
                });
}

/*
 * Evaluate a response from /liveness.
 * Check for Liveness Success, then check for Liveness Unsuccess (retry needed), else inform the caller that we should cancel.
 */
private void processLivenessResponseAndGoToNextStep(JSONObject responseJSON) {
        // Dynamically set the success message.
        // In the developer application, this may not be needed if the developer wishes to show a generic success message in all modes
        // or if the developer only uses ZoOm in one mode.
        ZoomCustomization.overrideResultScreenSuccessMessage = "Liveness Confirmed!";

        try {
                if(responseJSON.has("data") && responseJSON.getJSONObject("data").getInt("livenessStatus") == 0) {
                        zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.COMPLETED_SUCCESSFULLY;
                        zoomFaceMapResultCallback.succeed();
                }
                else if (responseJSON.has("data") && responseJSON.getJSONObject("data").getInt("livenessStatus") == 1) {
                        zoomFaceMapResultCallback.retry();
                }
                else {
                        zoomFaceMapResultCallback.cancel();
                }
                this.zoomFaceMapResultCallback = null;
        }
        catch(JSONException e) {
                e.printStackTrace();
                Log.d("ZoomSDK", "Error while parsing JSON result.");
                zoomFaceMapResultCallback.cancel();
                this.zoomFaceMapResultCallback = null;
        }
}

/*
 * Helper function to parse ZoomSessionResult and set more generic/friendly subcodes for consumers of ZoOm Managed Sessions.
 * Developers are encouraged to implement their own logic, logging, analytics here if desired.
 */
private void setUnsuccessSubCode(ZoomSessionResult zoomSessionResult)  {
        if(zoomSessionResult.getStatus() == ZoomSessionStatus.UNKNOWN_INTERNAL_ERROR) {
                zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.INTERNAL_UNSUCCESS;
        }
        else if(zoomSessionResult.getStatus() == ZoomSessionStatus.TIMEOUT) {
                zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.TIMEOUT;
        }
        else if(zoomSessionResult.getStatus() == ZoomSessionStatus.NON_PRODUCTION_MODE_LICENSE_INVALID) {
                zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.NETWORK_ERROR;
        }
        else if(zoomSessionResult.getStatus() == ZoomSessionStatus.LOCKED_OUT) {
                zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.LOCKED_OUT;
        }
        else if(zoomSessionResult.getStatus() == ZoomSessionStatus.MISSING_GUIDANCE_IMAGES) {
                zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.MISSING_GUIDANCE_IMAGES;
        }
        else if(zoomSessionResult.getStatus() == ZoomSessionStatus.CONTEXT_SWITCH) {
                zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.CONTEXT_SWITCH;
        }
        else if(zoomSessionResult.getStatus() == ZoomSessionStatus.CAMERA_INITIALIZATION_ISSUE || zoomSessionResult.getStatus() == ZoomSessionStatus.CAMERA_PERMISSION_DENIED) {
                zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.CAMERA_ERROR;
        }
        else if(zoomSessionResult.getStatus() == ZoomSessionStatus.LANDSCAPE_MODE_NOT_ALLOWED || zoomSessionResult.getStatus() == ZoomSessionStatus.REVERSE_PORTRAIT_NOT_ALLOWED) {
                zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.PORTRAIT_MODE_REQUIRED;
        }
        else if(zoomSessionResult.getStatus() == ZoomSessionStatus.USER_CANCELLED || zoomSessionResult.getStatus() == ZoomSessionStatus.USER_CANCELLED_VIA_HARDWARE_BUTTON) {
                zoomManagedSession.latestZoomManagedSessionStatusSubCode = ZoomManagedSession.ZoomManagedSessionStatusSubCode.USER_CANCELED;
        }
        else {
                Log.d("ZoomSDK", "Unexpected value found: " + zoomSessionResult.getStatus().toString());
        }
}

/*
 * Defines the callback that will be called to return the response from server calls.
 */
abstract class FaceTecManagedAPICallback {
public abstract void onResponse(JSONObject responseJSON);
}



}

class ZoomManagedSession {
// Must be set correctly in the constructor in order to use ZoOm
String deviceLicenseKeyIdentifier;

// By default, this points at the FaceTec Managed API.
// After deploying your own instance of the ZoOm Server REST SDK, this can be pointed at the Base URL that is created by the setup guide.
// In a final, production application, developers will be proxying calls through their own secure web service.
String zoomServerBaseURL;

// The mode of operation -- Liveness Check, Enrollment, Authentication, Identity Check
private ZoomManagedSessionMode mode;

// Keep track of the latest status of the Managed Session progress.
// This is updated throughout each ZoOm journey and can be interrogated after the process to understand what happened.
ZoomManagedSessionStatusSubCode latestZoomManagedSessionStatusSubCode;

// Keep a reference to the latest ZoOm Session Result.
private ZoomSessionResult latestZoomSessionResult;


// Keep track of latest response from FaceTec Managed API.
String latestFaceTecAPIResponseString;

// Used to call back to ZoomManagedSession caller with the overall result.
private ZoomManagedSession.ZoomManagedSessionCallback zoomManagedSessionCallback;

private static OkHttpClient _apiClient = null;

// DEVELOPER NOTE: Certain older devices with Android API 16-API 20 support TLS 1.1 by default and will not be able to communicate with the FaceTec
// Managed API. This is a specific behavior to the FaceTec Managed API. Developers most likely have their own code for communicating with their own APIs,
// and thus this code will most likely be overridden by new code here.
static OkHttpClient createApiClient() {
        return new OkHttpClient();
}

static synchronized OkHttpClient getApiClient() {
        if (_apiClient == null) {
                _apiClient = createApiClient();
        }
        return _apiClient;
}
/*
 * Check parameters, store local references, and kick off the ZoomSession!
 */
public ZoomManagedSession(final ZoomManagedSession.ZoomManagedSessionCallback zoomManagedSessionCallback, Context context, String deviceLicenseKeyIdentifier, String zoomServerBaseURL, final ZoomManagedSessionMode mode, final String enrollmentIdentifier) {
        this.zoomManagedSessionCallback = zoomManagedSessionCallback;
        this.latestZoomManagedSessionStatusSubCode = ZoomManagedSessionStatusSubCode.NEVER_STARTED;
        this.mode = mode;
        this.deviceLicenseKeyIdentifier = deviceLicenseKeyIdentifier;
        this.zoomServerBaseURL = zoomServerBaseURL;

        if(mode == ZoomManagedSessionMode.IDENTITY_CHECK) {
                ZoomManagedSessionFaceMapProcessor faceMapProcessor = new ZoomManagedSessionFaceMapProcessor(this, enrollmentIdentifier);
                ZoomSessionActivity.createAndLaunchZoomSession(context, faceMapProcessor);
        }
        else {
                ZoomManagedSessionFaceMapProcessor faceMapProcessor = new ZoomManagedSessionFaceMapProcessor(this, enrollmentIdentifier);
                ZoomSessionActivity.createAndLaunchZoomSession(context, faceMapProcessor);
        }
}

public ZoomManagedSession(ZoomManagedSession.ZoomManagedSessionCallback zoomManagedSessionCallback, Context context, String deviceLicenseKeyIdentifier, String zoomServerBaseURL, ZoomManagedSessionMode mode) {
        this(zoomManagedSessionCallback, context, deviceLicenseKeyIdentifier, zoomServerBaseURL, mode, null);
}

public void processZoomManagedSessionResult(int requestCode, int resultCode, Intent data) {
        if(resultCode != Activity.RESULT_OK) {
                latestZoomManagedSessionStatusSubCode = ZoomManagedSessionStatusSubCode.INTERNAL_UNSUCCESS;
                zoomManagedSessionCallback.onZoomManagedSessionComplete(ZoomManagedSessionStatus.UNSUCCESS_CHECK_SUBCODE);
        }

        // Save results
        ZoomSessionResult zoomSessionResult = ZoomSessionActivity.getZoomSessionResultFromActivityResult(data);
        this.latestZoomSessionResult = zoomSessionResult;
        if(latestZoomManagedSessionStatusSubCode == ZoomManagedSessionStatusSubCode.COMPLETED_SUCCESSFULLY) {
                zoomManagedSessionCallback.onZoomManagedSessionComplete(ZoomManagedSessionStatus.SUCCESS);
        }
        else {
                zoomManagedSessionCallback.onZoomManagedSessionComplete(ZoomManagedSessionStatus.UNSUCCESS_CHECK_SUBCODE);
        }
}

/*
 * This is the callback back to the ZoomManagedSession caller with the overall status.
 * Developers must implement this and pass into the ZoomManagedSession constructor.
 */
public abstract static class ZoomManagedSessionCallback {
public ZoomManagedSessionCallback() {
}
abstract public void onZoomManagedSessionComplete(ZoomManagedSessionStatus status);
}

/*
 * This returns a simple enum of Success and UnsuccessCheckSubCode.
 * Callers can get more granular information by interrogating the ZoomManagedSession class helper functions.
 */
public enum ZoomManagedSessionStatus {
        SUCCESS("Managed session processed successfully."),
        UNSUCCESS_CHECK_SUBCODE("Managed session was not successful. Check the managed session subCode for more details.");

        private final String name;

        ZoomManagedSessionStatus(String name) {
                this.name = name;
        }

        public String toString() {
                return this.name;
        }
}

/*
 * The general scenario or mode of operation for ZoOm.  This controls aspects of the UX,
 * as well as the handling of the result.
 *
 * Developers can alter this to tailor to their own application or not use these modes to control logic if desired.
 */
public enum ZoomManagedSessionMode {
        LIVENESS,
        ENROLL,
        AUTHENTICATE,
        IDENTITY_CHECK
}

/*
 * These are the general "non-nominal" occurrences during a ZoOm Sesion or ZoOm Identity Check.
 *
 * Developers can alter this to tailor to their own application or not use these subcodes if desired.
 */
public enum ZoomManagedSessionStatusSubCode {
        NEVER_STARTED("The session was never started."),
        INVALID_MANAGED_SESSION_PARAMETERS("The manged session parameters are invalid."),
        INTERNAL_UNSUCCESS("Session failed for an unknown internal reason."),
        PORTRAIT_MODE_REQUIRED("Portrait mode is required."),
        CAMERA_ERROR("Unable to initialize the camera."),
        LOCKED_OUT("The user is locked out."),
        CONTEXT_SWITCH("Session cancelled because of OS context switch."),
        USER_CANCELED("Session cancelled by the user."),
        TIMEOUT("Session cancelled due to timeout."),
        NETWORK_ERROR("Network connectivity issue encountered."),
        MISSING_GUIDANCE_IMAGES("Guidance images were not provided."),
        COMPLETED_SUCCESSFULLY("The Managed Session processed successfully."),
        CHECK_LATEST_FACETEC_API_RESPONSE_STRING("FaceTec API returned an unsuccess result. Check the latestFaceTecAPIString for details.");

        private final String name;

        ZoomManagedSessionStatusSubCode(String name) {
                this.name = name;
        }

        public String toString() {
                return this.name;
        }
}

/*
 * ZoomManagedSession provides convenience functions to check if an enrollmentIdentifier is enrolled
 * in the FaceTec Managed API (or ZoOm Server REST SDK).  These are the possible statuses of a check to /enrollment/:id
 */
public enum EnrollmentStatus {
        ENROLLED,
        NOT_ENROLLED,
        NETWORK_ERROR
}

/*
 * Checks if an enrollmentIdentifier is enrolled and returns the status back to the caller.
 */

/*
 * Get the mode that was set.
 */
public ZoomManagedSessionMode getMode() {
        return mode;
}

/*
 * Get the latest ZoomSessionResult.
 */
public ZoomSessionResult getLatestZoomSessionResult() {
        return latestZoomSessionResult;
}

/*
 * Set the latest ZoomSessionResult.
 */
void setLatestZoomSessionResult(ZoomSessionResult result) {
        this.latestZoomSessionResult = result;
}

/*
 * Get the latest response from the FaceTec Managed API.
 */
public String getFaceTecAPIResponseString() {
        return latestFaceTecAPIResponseString;
}


/*
 * Get the last subcode we set ourselves to.  At the end of the process, this is indicative of either success or a granular reason why the session was cancelled or failed.
 */
public ZoomManagedSessionStatusSubCode getLatestZoomManagedSessionStatusSubCode() {
        return latestZoomManagedSessionStatusSubCode;
}

/*
 * Defines the callback that will be called to convey the status of an enrollment.
 */
static public abstract class EnrollmentStatusCallback {
public abstract void onResult(EnrollmentStatus status);
}

/*
 * Defines the callback that will be called to convey the status of a deletion of an enrollment.
 */
static public abstract class DeleteUserCallback {
public abstract void onResult(boolean isDeleted);
}
}

/*
 * Implementation of RequestBody that allows upload progress to be retrieved
 */
class ProgressRequestBody extends RequestBody {
private final RequestBody requestBody;
private Listener listener;

ProgressRequestBody(RequestBody requestBody, Listener listener) {
        this.requestBody = requestBody;
        this.listener = listener;
}

@Override
public MediaType contentType() {
        return requestBody.contentType();
}

@Override
public long contentLength() throws IOException {
        return requestBody.contentLength();
}

@Override
public void writeTo(BufferedSink sink) throws IOException {
        ProgressStream progressStream = new ProgressStream(sink.outputStream(), contentLength());
        BufferedSink progressSink = Okio.buffer(Okio.sink(progressStream));
        requestBody.writeTo(progressSink);
        progressSink.flush();
}

protected final class ProgressStream extends OutputStream {
private final OutputStream stream;
private long totalBytes;
private long bytesSent;

ProgressStream(OutputStream stream, long totalBytes) {
        this.stream = stream;
        this.totalBytes = totalBytes;
}

@Override
public void write(@NonNull byte[] b, int off, int len) throws IOException {
        this.stream.write(b, off, len);
        if(len < b.length) {
                this.bytesSent += len;
        }
        else {
                this.bytesSent += b.length;
        }
        listener.onUploadProgressChanged(this.bytesSent, this.totalBytes);
}

@Override
public void write(int b) throws IOException {
        this.stream.write(b);
        this.bytesSent += 1;
        listener.onUploadProgressChanged(this.bytesSent, this.totalBytes);
}
}

public interface Listener {
void onUploadProgressChanged(long bytesWritten, long totalBytes);
}
}
