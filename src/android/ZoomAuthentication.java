package com.facetec.cordova;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.support.annotation.NonNull;

import com.facetec.zoom.sdk.ZoomAuthenticationActivity;
import com.facetec.zoom.sdk.ZoomAuthenticationResult;
import com.facetec.zoom.sdk.ZoomAuthenticationStatus;
import com.facetec.zoom.sdk.ZoomAuthenticatorState;
import com.facetec.zoom.sdk.ZoomEnrollmentActivity;
import com.facetec.zoom.sdk.ZoomEnrollmentResult;
import com.facetec.zoom.sdk.ZoomEnrollmentStatus;
import com.facetec.zoom.sdk.ZoomLivenessResult;
import com.facetec.zoom.sdk.ZoomSDK;
import com.facetec.zoom.sdk.ZoomSDK.ZoomSDKStatus;
import com.facetec.zoom.sdk.ZoomVerificationActivity;
import com.facetec.zoom.sdk.ZoomVerificationResult;
import com.facetec.zoom.sdk.ZoomVerificationStatus;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import static com.facetec.zoom.sdk.ZoomAuthenticationStatus.USER_WAS_AUTHENTICATED;
import static com.facetec.zoom.sdk.ZoomAuthenticationStatus.USER_WAS_AUTHENTICATED_WITH_FALLBACK_STRATEGY;
import static com.facetec.zoom.sdk.ZoomEnrollmentStatus.USER_WAS_ENROLLED;
import static com.facetec.zoom.sdk.ZoomEnrollmentStatus.USER_WAS_ENROLLED_WITH_FALLBACK_STRATEGY;

/**
 * This class echoes a string called from JavaScript.
 */
public class ZoomAuthentication extends CordovaPlugin {

    private CallbackContext pendingCallbackContext = null;

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
        else {
            return false;
        }
        return true;
    }

    private void initialize(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final String appToken = args.getString(0);

        final Context context = this.cordova.getActivity().getApplicationContext();

        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                ZoomSDK.preload(context);
                ZoomSDK.initialize(context, appToken, new ZoomSDK.InitializeCallback() {
                    @Override
                    public void onCompletion(boolean successful) {
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

    private void enroll(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        String userId = args.getString(0);
        String secret = args.getString(1);

        Intent enrollmentIntent = new Intent(this.cordova.getActivity(), ZoomEnrollmentActivity.class);
        enrollmentIntent.putExtra(ZoomSDK.EXTRA_ENROLLMENT_USER_ID, userId);
        enrollmentIntent.putExtra(ZoomSDK.EXTRA_USER_ENCRYPTION_SECRET, secret);

        pendingCallbackContext = callbackContext;

        this.cordova.startActivityForResult(this, enrollmentIntent, ZoomSDK.REQUEST_CODE_ENROLLMENT);
    }

    private void authenticate(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        String userId = args.getString(0);
        String secret = args.getString(1);

        Intent authenticationIntent = new Intent(this.cordova.getActivity(), ZoomAuthenticationActivity.class);
        authenticationIntent.putExtra(ZoomSDK.EXTRA_AUTHENTICATION_USER_ID, userId);
        authenticationIntent.putExtra(ZoomSDK.EXTRA_USER_ENCRYPTION_SECRET, secret);

        pendingCallbackContext = callbackContext;

        this.cordova.startActivityForResult(this, authenticationIntent, ZoomSDK.REQUEST_CODE_AUTHENTICATION);
    }

    private void verify(JSONArray args, final CallbackContext callbackContext) throws JSONException {

        Intent verificationIntent = new Intent(this.cordova.getActivity(), ZoomVerificationActivity.class);

        pendingCallbackContext = callbackContext;

        this.cordova.startActivityForResult(this, verificationIntent, ZoomSDK.REQUEST_CODE_VERIFICATION);
    }

    private void getUserEnrollmentStatus(JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final Context context = this.cordova.getActivity().getApplicationContext();
        final String userId = args.getString(0);

        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                ZoomSDK.UserEnrollmentStatus status = ZoomSDK.getUserEnrollmentStatus(context, userId);
                switch (status) {
                    case USER_ENROLLED:
                        callbackContext.success("Enrolled");
                        break;
                    case USER_INVALIDATED:
                        callbackContext.success("Invalidated");
                        break;
                    case USER_NOT_ENROLLED:
                    default:
                        callbackContext.success("NotEnrolled");
                }
            }
        });
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == Activity.RESULT_OK) {
            try {
                //
                // result from enrollment
                //
                if (requestCode == ZoomSDK.REQUEST_CODE_ENROLLMENT) {
                    ZoomEnrollmentResult result = data.getParcelableExtra(ZoomSDK.EXTRA_ENROLL_RESULTS);
                    JSONObject resultObj = convertZoomEnrollmentResult(result);

                    pendingCallbackContext.success(resultObj);
                    pendingCallbackContext = null;
                }
                //
                // result from authentication
                //
                else if (requestCode == ZoomSDK.REQUEST_CODE_AUTHENTICATION) {
                    ZoomAuthenticationResult result = data.getParcelableExtra(ZoomSDK.EXTRA_AUTH_RESULTS);
                    JSONObject resultObj = convertZoomAuthenticationResult(result);

                    pendingCallbackContext.success(resultObj);
                    pendingCallbackContext = null;
                }
                //
                // result from verification
                //
                else if (requestCode == ZoomSDK.REQUEST_CODE_VERIFICATION) {
                    ZoomVerificationResult result = data.getParcelableExtra(ZoomSDK.EXTRA_VERIFY_RESULTS);
                    JSONObject resultObj = convertZoomVerificationResult(result);

                    pendingCallbackContext.success(resultObj);
                    pendingCallbackContext = null;
                }
                else {
                    pendingCallbackContext.error("Unexpected request code (" + requestCode + ")");
                }
            }
            catch (Exception e) {
                pendingCallbackContext.error(e.getMessage());
            }
        }
        else {
            pendingCallbackContext.error("Unexpected result code (" + resultCode + ")");
            pendingCallbackContext = null;
        }
    }

    @NonNull
    private String getSdkStatusString() {
        Context context = this.cordova.getActivity().getApplicationContext();
        ZoomSDKStatus status = ZoomSDK.getStatus(context);

        switch (status) {
            case NEVER_INITIALIZED:
                return "NeverInitialized";
            case INITIALIZED:
                return "Initialized";
            case INVALID_TOKEN:
                return "InvalidToken";
            case VERSION_DEPRECATED:
                return "VersionDeprecated";
            case DEVICE_INSECURE:
                return "DeviceInsecure";
            case NETWORK_ISSUES:
                return "NetworkIssues";
            case OFFLINE_SESSIONS_EXCEEDED:
                return "OfflineSessionsExceeded";
        }

        return "UnknownStatus";
    }

    private static JSONObject convertZoomEnrollmentResult(ZoomEnrollmentResult result) throws JSONException {
        JSONObject resultObj = new JSONObject();

        ZoomEnrollmentStatus status = result.getStatus();
        resultObj.put("successful", (status == USER_WAS_ENROLLED || status == USER_WAS_ENROLLED_WITH_FALLBACK_STRATEGY));
        resultObj.put("status", convertZoomEnrollmentStatus(status));
        resultObj.put("faceEnrollmentState", convertZoomAuthenticatorState(result.getFaceEnrollmentState()));
        resultObj.put("livenessResult", convertZoomLivenessResult(result.getFaceMetrics().getLiveness()));

        return resultObj;
    }

    private static JSONObject convertZoomAuthenticationResult(ZoomAuthenticationResult result) throws JSONException {
        JSONObject resultObj = new JSONObject();

        ZoomAuthenticationStatus status = result.getStatus();
        resultObj.put("successful", (status == USER_WAS_AUTHENTICATED || status == USER_WAS_AUTHENTICATED_WITH_FALLBACK_STRATEGY));
        resultObj.put("status", convertZoomAuthenticationStatus(status));
        resultObj.put("faceAuthenticatorState", convertZoomAuthenticatorState(result.getFaceZoomAuthenticatorState()));
        resultObj.put("livenessResult", convertZoomLivenessResult(result.getFaceMetrics().getLiveness()));
        resultObj.put("countOfFaceFailuresSinceLastSuccess", result.getCountOfFaceFailuresSinceLastSuccess());
        resultObj.put("consecutiveLockouts", result.getConsecutiveLockouts());

        return resultObj;
    }

    private static JSONObject convertZoomVerificationResult(ZoomVerificationResult result) throws JSONException {
        JSONObject resultObj = new JSONObject();

        ZoomVerificationStatus status = result.getStatus();
        resultObj.put("successful", (status == ZoomVerificationStatus.USER_PROCESSED_SUCCESSFULLY));
        resultObj.put("status", convertZoomVerificationStatus(status));

        return resultObj;
    }

    private static String convertZoomEnrollmentStatus(ZoomEnrollmentStatus status) {
        // Note: These string values should match exactly with the iOS implementation
        switch (status) {
            case APP_TOKEN_NOT_VALID:
                return "InvalidToken";
            case USER_WAS_ENROLLED:
            case USER_WAS_ENROLLED_WITH_FALLBACK_STRATEGY:
                return "Enrolled";
            case USER_CANCELLED:
                return "UserCancelled";
            case ENROLLMENT_TIMED_OUT:
                return "Timeout";
            case FAILED_DUE_TO_CAMERA_ERROR:
                return "CameraError";
            case FAILED_DUE_TO_INTERNAL_ERROR:
                return "InternalError";
            case FAILED_DUE_TO_OS_CONTEXT_SWITCH:
                return "OSContextSwitch";
            case NETWORKING_MISSING_IN_DEV_MODE:
                return "NoConnectionInDevMode";
            case CAMERA_PERMISSION_DENIED:
                return "CameraPermissionDenied";
            case USER_NOT_ENROLLED:
            case FAILED_BECAUSE_USER_COULD_NOT_VALIDATE_FINGERPRINT:
                return "NotEnrolled";
        }

        return "UnknownStatus";
    }

    private static String convertZoomAuthenticationStatus(ZoomAuthenticationStatus status) {
        // Note: These string values should match exactly with the iOS implementation
        switch (status) {
            case APP_TOKEN_NOT_VALID:
                return "AppTokenNotValid";
            case USER_WAS_AUTHENTICATED:
            case USER_WAS_AUTHENTICATED_WITH_FALLBACK_STRATEGY:
                return "Authenticated";
            case AUTHENTICATION_TIMED_OUT:
                return "Timeout";
            case USER_FAILED_AUTHENTICATION:
                return "FailedAuthentication";
            case NETWORKING_MISSING_IN_DEV_MODE:
                return "NoConnectionInDevMode";
            case CAMERA_PERMISSIONS_DENIED:
                return "CameraPermissionDenied";
            case USER_MUST_ENROLL:
                return "UserMustEnroll";
            case USER_FAILED_AUTHENTICATION_AND_WAS_DELETED:
                return "FailedAndWasDeleted";
            case SESSION_FAILED_DUE_TO_OS_CONTEXT_SWITCH:
                return "OSContextSwitch";
            case FAILED_DUE_TO_CAMERA_ERROR:
                return "CameraError";
            case FAILED_DUE_TO_INTERNAL_ERROR:
                return "InternalError";
            case USER_CANCELLED:
                return "UserCancelled";
        }

        return "UnknownStatus";
    }

    private static String convertZoomVerificationStatus(ZoomVerificationStatus status) {
        switch (status) {
            case USER_PROCESSED_SUCCESSFULLY:
                return "ProcessedSuccessfully";
            case USER_NOT_PROCESSED:
                return "NotProcessed";
            case APP_TOKEN_NOT_VALID:
                return "AppTokenNotValid";
            case NETWORKING_MISSING_IN_DEV_MODE:
                return "NoConnectionInDevMode";
            case FAILED_DUE_TO_CAMERA_ERROR:
                return "CameraError";
            case FAILED_DUE_TO_INTERNAL_ERROR:
                return "InternalError";
            case USER_CANCELLED:
                return "UserCancelled";
        }

        return "UnknownStatus";
    }

    private static String convertZoomAuthenticatorState(ZoomAuthenticatorState state) {
        switch (state) {
            case COMPLETED:
                return "Completed";
            case FAILED:
                return "Failed";
            case CANCELLED:
                return "Cancelled";
            case UNUSED:
            default:
                return "Unused";
        }
    }

    private static String convertZoomLivenessResult(ZoomLivenessResult result) {
        switch (result) {
            case ALIVE:
                return "Alive";
            case LIVENESS_UNDETERMINED:
            default:
                return "Undetermined";
        }
    }
}
