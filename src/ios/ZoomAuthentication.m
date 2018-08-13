/********* ZoomAuthentication.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
@import ZoomAuthentication;

@interface ZoomAuthentication : CDVPlugin <ZoomEnrollmentDelegate, ZoomAuthenticationDelegate, ZoomVerificationDelegate> {
    CDVInvokedUrlCommand* pendingCommand;
}

- (void)getVersion:(CDVInvokedUrlCommand*)command;
- (void)getUserEnrollmentStatus:(CDVInvokedUrlCommand*)command;
- (void)getSdkStatus:(CDVInvokedUrlCommand*)command;

- (void)initialize:(CDVInvokedUrlCommand*)command;

- (void)enroll:(CDVInvokedUrlCommand*)command;

- (void)authenticate:(CDVInvokedUrlCommand*)command;

- (void)verify:(CDVInvokedUrlCommand*)command;

@end

@implementation ZoomAuthentication

- (void)initialize:(CDVInvokedUrlCommand*)command
{
    NSString* appToken = [command.arguments objectAtIndex:0];
    
    [[Zoom sdk] preload]; // Currently MUST be called from UI thread
    
    [self.commandDelegate runInBackground:^{
        
        [[Zoom sdk] initializeWithAppToken:appToken completion: ^ void (BOOL validationResult) {
            CDVPluginResult* pluginResult;
            if (validationResult) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            else {
                NSString* status = [self getSdkStatusString];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:status];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)enroll:(CDVInvokedUrlCommand*)command
{
    NSString* userId = [command.arguments objectAtIndex:0];
    NSString* encryptionSecret = [command.arguments objectAtIndex:1];
    
    UIViewController *vc = [[Zoom sdk] createEnrollmentVCWithDelegate:self userID:userId applicationPerUserEncryptionSecret:encryptionSecret secret:nil];
    
    pendingCommand = command;
    [self.viewController presentViewController:vc animated:true completion:nil];
}

- (void)authenticate:(CDVInvokedUrlCommand*)command
{
    NSString* userId = [command.arguments objectAtIndex:0];
    NSString* encryptionSecret = [command.arguments objectAtIndex:1];

    UIViewController *vc = [[Zoom sdk] createAuthenticationVCWithDelegate:self userID:userId applicationPerUserEncryptionSecret:encryptionSecret ];

    pendingCommand = command;
    [self.viewController presentViewController:vc animated:true completion:nil];
}

- (void)verify:(CDVInvokedUrlCommand*)command
{
    UIViewController *vc = [[Zoom sdk] createVerificationVCWithDelegate:self verificationImages:NULL retrieveZoomBiometric:false ];
    
    pendingCommand = command;
    [self.viewController presentViewController:vc animated:true completion:nil];
}

- (void)getVersion:(CDVInvokedUrlCommand*)command
{
    NSString* version = [[Zoom sdk] version];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:version];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getUserEnrollmentStatus:(CDVInvokedUrlCommand*)command
{
    NSString* userId = [command.arguments objectAtIndex:0];
    
    [self.commandDelegate runInBackground:^{
        ZoomUserEnrollmentStatus status = [[Zoom sdk] getUserEnrollmentStatusWithUserID:userId];
        NSString* statusStr;
        
        switch (status) {
            case ZoomUserEnrollmentStatusUserEnrolled:
                statusStr = @"Enrolled";
                break;
            case ZoomUserEnrollmentStatusUserNotEnrolled:
                statusStr = @"NotEnrolled";
                break;
            case ZoomUserEnrollmentStatusUserInvalidated:
                statusStr = @"Invalidated";
                break;
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:statusStr];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getSdkStatus:(CDVInvokedUrlCommand*)command
{
    NSString* status = [self getSdkStatusString];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) onZoomEnrollmentResultWithResult:(ZoomEnrollmentResult *)result {
    ZoomEnrollmentStatus status = [result status];
    NSDictionary* resultDict = @{
        @"successful": (status == ZoomEnrollmentStatusUserWasEnrolled ? @YES : @NO),
        @"status": [self convertZoomEnrollmentStatus:status],
        @"faceEnrollmentState": [self convertZoomAuthenticatorState:[result faceEnrollmentState]],
        @"livenessResult": [self convertZoomLivenessResult:[[result faceMetrics] livenessResult]]
    };
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:pendingCommand.callbackId];
    pendingCommand = nil;
}

- (void) onZoomAuthenticationResultWithResult:(ZoomAuthenticationResult *)result {
    ZoomAuthenticationStatus status = [result status];
    NSDictionary* resultDict = @{
        @"successful": (status == ZoomAuthenticationStatusUserWasAuthenticated ? @YES : @NO),
        @"status": [self convertZoomAuthenticationStatus:status],
        @"faceAuthenticatorState": [self convertZoomAuthenticatorState:[result faceAuthenticatorState]],
        @"livenessResult": [self convertZoomLivenessResult:[[result faceMetrics] livenessResult]],
        @"countOfFaceFailuresSinceLastSuccess": [NSNumber numberWithInteger:[result countOfFaceFailuresSinceLastSuccess]],
        @"consecutiveLockouts": [NSNumber numberWithInteger:[result consecutiveLockouts]]
    };
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:pendingCommand.callbackId];
    pendingCommand = nil;
}

- (void) onZoomVerificationResultWithResult:(ZoomVerificationResult *)result {
    ZoomVerificationStatus status = [result status];
    NSDictionary* resultDict = @{
        @"successful": (status == ZoomVerificationStatusUserProcessedSuccessfully ? @YES : @NO),
        @"status": [self convertZoomVerificationStatus:status],
        @"livenessResult": [self convertZoomLivenessResult:[[result faceMetrics] livenessResult]],
    };
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:pendingCommand.callbackId];
    pendingCommand = nil;
}

- (NSString*)convertZoomEnrollmentStatus:(ZoomEnrollmentStatus)status {
    // Note: These string values should match exactly with the Android implementation
    switch (status) {
        case ZoomEnrollmentStatusUserWasEnrolled:
            return @"Enrolled";
        case ZoomEnrollmentStatusUserNotEnrolled:
            return @"NotEnrolled";
        case ZoomEnrollmentStatusFailedBecauseOfTimeout:
            return @"Timeout";
        case ZoomEnrollmentStatusFailedBecauseOfLowMemory:
            return @"LowMemory";
        case ZoomEnrollmentStatusFailedBecauseUserCancelled:
            return @"UserCancelled";
        case ZoomEnrollmentStatusFailedBecauseAppTokenNotValid:
            return @"AppTokenNotValid";
        case ZoomEnrollmentStatusFailedBecauseOfOSContextSwitch:
            return @"OSContextSwitch";
        case ZoomEnrollmentStatusFailedBecauseOfDiskWriteError:
            return @"DiskWriteError";
        case ZoomEnrollmentStatusFailedBecauseNoConnectionInDevMode:
            return @"NoConnectionInDevMode";
        case ZoomEnrollmentStatusFailedBecauseCameraPermissionDeniedByUser:
        case ZoomEnrollmentStatusFailedBecauseCameraPermissionDeniedByAdministrator:
            return @"CameraPermissionsDenied";
        case ZoomEnrollmentStatusUserFailedToProvideGoodEnrollment:
        default:
            return @"NotEnrolled";
    }
}

- (NSString*)convertZoomAuthenticationStatus:(ZoomAuthenticationStatus)status {
    // Note: These string values should match exactly with the Android implementation
    switch (status) {
        case ZoomAuthenticationStatusUserWasAuthenticated:
            return @"Authenticated";
        case ZoomAuthenticationStatusFailedBecauseOfTimeout:
            return @"Timeout";
        case ZoomAuthenticationStatusFailedBecauseOfLowMemory:
            return @"LowMemory";
        case ZoomAuthenticationStatusFailedBecauseUserCancelled:
            return @"UserCancelled";
        case ZoomAuthenticationStatusFailedBecauseUserMustEnroll:
            return @"UserMustEnroll";
        case ZoomAuthenticationStatusFailedBecauseAppTokenNotValid:
            return @"AppTokenNotValid";
        case ZoomAuthenticationStatusFailedBecauseOfOSContextSwitch:
            return @"OSContextSwitch";
        case ZoomAuthenticationStatusFailedBecauseTouchIDUnavailable:
            return @"TouchIDUnavailable";
        case ZoomAuthenticationStatusFailedBecauseNoConnectionInDevMode:
            return @"NoConnectionInDevMode";
        case ZoomAuthenticationStatusFailedBecauseCameraPermissionDenied:
            return @"CameraPermissionDenied";
        case ZoomAuthenticationStatusFailedBecauseTouchIDSettingsChanged:
            return @"TouchIDSettingsChanged";
        case ZoomAuthenticationStatusFailedBecauseUserFailedAuthentication:
            return @"FailedAuthentication";
        case ZoomAuthenticationStatusFailedToAuthenticateTooManyTimesAndUserWasDeleted:
            return @"FailedAndWasDeleted";
        case ZoomAuthenticationStatusFailedBecauseOfflineSessionsExceeded:
            return @"OfflineSessionsExceeded";
        case ZoomAuthenticationStatusFailedBecauseEncryptionKeyInvalid:
            return @"EncryptionKeyInvalid";
        case ZoomAuthenticationStatusFailedBecauseCouldNotRetrieveBiometricDataForUser:
            return @"CouldNotRetrieveBiometricDataForUser";
        case ZoomAuthenticationStatusFailedBecauseEncryptionSecretInvalid:
            return @"EncryptionSecretInvalid";
    }
    return (NSString*)nil;
}

- (NSString*)convertZoomVerificationStatus:(ZoomVerificationStatus)status {
    switch (status) {
        case ZoomVerificationStatusUserProcessedSuccessfully:
            return @"ProcessedSuccessfully";
        case ZoomVerificationStatusUserNotProcessed:
            return @"UserNotProcessed";
        case ZoomVerificationStatusFailedBecauseUserCancelled:
            return @"UserCancelled";
        case ZoomVerificationStatusFailedBecauseAppTokenNotValid:
            return @"AppTokenNotValid";
        case ZoomVerificationStatusFailedBecauseCameraPermissionDeniedByUser:
        case ZoomVerificationStatusFailedBecauseCameraPermissionDeniedByAdministrator:
             return @"CameraPermissionsDenied";
        case ZoomVerificationStatusFailedBecauseOfOSContextSwitch:
            return @"OSContextSwitch";
        case ZoomVerificationStatusFailedBecauseOfTimeout:
            return @"Timeout";
        case ZoomVerificationStatusFailedBecauseOfLowMemory:
            return @"LowMemory";
        case ZoomVerificationStatusFailedBecauseOfDiskWriteError:
            return @"DiskWriteError";
        case ZoomVerificationStatusFailedBecauseNoConnectionInDevMode:
            return @"NoConnectionInDevMode";
        case ZoomVerificationStatusFailedBecauseOfflineSessionsExceeded:
            return @"OfflineSessionsExceeded";
        case ZoomVerificationStatusFailedBecauseEncryptionKeyInvalid:
            return @"EncryptionKeyInvalid";
    }
}

- (NSString*)getSdkStatusString {
    switch ([[Zoom sdk] getStatus]) {
        case ZoomSDKStatusNeverInitialized:
            return @"NeverInitialized";
        case ZoomSDKStatusInitialized:
            return @"Initialized";
        case ZoomSDKStatusNetworkIssues:
            return @"NetworkIssues";
        case ZoomSDKStatusInvalidToken:
            return @"InvalidToken";
        case ZoomSDKStatusDeviceInsecure:
            return @"DeviceInsecure";
        case ZoomSDKStatusVersionDeprecated:
            return @"VersionDeprecated";
        case ZoomSDKStatusOfflineSessionsExceeded:
            return @"OfflineSessionsExceeded";
            break;
    }
    return nil;
}

- (NSString*)convertZoomAuthenticatorState:(ZoomAuthenticatorState)state {
    switch (state) {
        case ZoomAuthenticatorStateFailed:
            return @"Failed";
        case ZoomAuthenticatorStateUnused:
            return @"Unused";
        case ZoomAuthenticatorStateCancelled:
            return @"Cancelled";
        case ZoomAuthenticatorStateCompleted:
            return @"Completed";
    }
}

- (NSString*)convertZoomLivenessResult:(ZoomLivenessResult)result {
    switch (result) {
        case ZoomLivenessResultAlive:
            return @"Alive";
        case ZoomLivenessResultLivenessUndetermined:
            return @"Undetermined";
    }
}

@end
