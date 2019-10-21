/********* ZoomAuthEval.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <ZoomAuthentication/ZoomAuthentication.h>

#ifndef __CORDOVA_4_0_0
#import <Cordova/NSData+Base64.h>
#endif


@interface ZoomAuthEval : CDVPlugin < ZoomManagedSessionDelegate> {
    CDVInvokedUrlCommand* pendingCommand;
}

- (void)getVersion:(CDVInvokedUrlCommand*)command;
- (void)getUserEnrollmentStatus:(CDVInvokedUrlCommand*)command;
- (void)getSdkStatus:(CDVInvokedUrlCommand*)command;
- (void)initialize:(CDVInvokedUrlCommand*)command;
- (void)enroll:(CDVInvokedUrlCommand*)command;
- (void)authenticate:(CDVInvokedUrlCommand*)command;
- (void)verify:(CDVInvokedUrlCommand*)command;
- (void)setPublicKey:(CDVInvokedUrlCommand*)command;
- (void)setServerUrl:(CDVInvokedUrlCommand*)command;
- (void)setBrandingLogo:(CDVInvokedUrlCommand*)command;
- (void)setMainForeGroundColor:(CDVInvokedUrlCommand*)command;
- (void)setMainBackGroundColor:(CDVInvokedUrlCommand*)command;

- (void)idCheck:(CDVInvokedUrlCommand*)command;
- (void)deleteEnrollment:(CDVInvokedUrlCommand*)command;
- (void)auditTrail:(CDVInvokedUrlCommand*)command;
- (void)setDefaultTheme:(CDVInvokedUrlCommand*)command;
- (void)setDarkTheme:(CDVInvokedUrlCommand*)command;
- (void)setMidnightTheme:(CDVInvokedUrlCommand*)command;
- (void)setSunsetTheme:(CDVInvokedUrlCommand*)command;
- (void)onZoomManagedSessionCompleteWithStatus:(ZoomManagedSessionStatus)zoomManagedSessionStatus;

@end

static NSString *appToken = @"";
static NSString *publicKey = @"-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5PxZ3DLj+zP6T6HFgzzk\nM77LdzP3fojBoLasw7EfzvLMnJNUlyRb5m8e5QyyJxI+wRjsALHvFgLzGwxM8ehz\nDqqBZed+f4w33GgQXFZOS4AOvyPbALgCYoLehigLAbbCNTkeY5RDcmmSI/sbp+s6\nmAiAKKvCdIqe17bltZ/rfEoL3gPKEfLXeN549LTj3XBp0hvG4loQ6eC1E1tRzSkf\nGJD4GIVvR+j12gXAaftj3ahfYxioBH7F7HQxzmWkwDyn3bqU54eaiB7f0ftsPpWM\nceUaqkL2DZUvgN0efEJjnWy5y1/Gkq5GGWCROI9XG/SwXJ30BbVUehTbVcD70+ZF\n8QIDAQAB\n-----END PUBLIC KEY-----";

static NSString* toBase64(NSData* data) {
    SEL s1 = NSSelectorFromString(@"cdv_base64EncodedString");
    SEL s2 = NSSelectorFromString(@"base64EncodedString");
    SEL s3 = NSSelectorFromString(@"base64EncodedStringWithOptions:");
    
    if ([data respondsToSelector:s1]) {
        NSString* (*func)(id, SEL) = (void *)[data methodForSelector:s1];
        return func(data, s1);
    } else if ([data respondsToSelector:s2]) {
        NSString* (*func)(id, SEL) = (void *)[data methodForSelector:s2];
        return func(data, s2);
    } else if ([data respondsToSelector:s3]) {
        NSString* (*func)(id, SEL, NSUInteger) = (void *)[data methodForSelector:s3];
        return func(data, s3, 0);
    } else {
        return nil;
    }
}

@implementation ZoomAuthEval

NSString* lastAction = @"";
NSString *urlString = @"https://api.zoomauth.com/api/v2/biometrics";
ZoomCustomization *zoomCustomization;
ZoomManagedSession *zoomManagedSession;
NSArray * auditImagesArray;

- (void)initialize:(CDVInvokedUrlCommand*)command
{
    appToken = [command.arguments objectAtIndex:0];
    [Zoom.sdk setFaceMapEncryptionKeyWithPublicKey: publicKey];
    
    [Zoom.sdk preload]; // Currently MUST be called from UI thread
    zoomCustomization = [[ZoomCustomization alloc] init];
    auditImagesArray = [[NSArray alloc] init];
    [self.commandDelegate runInBackground:^{
        
        [Zoom.sdk initialize:appToken
                  completion:^ void (BOOL initializationSuccessful)
         {
            CDVPluginResult* pluginResult;
            NSString* status = [self getSdkStatusString];
            if(!initializationSuccessful) {
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:status];
            }else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsString:status];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            // Ready to launch ZoOm!
        }];
    }];
}

- (void)enroll:(CDVInvokedUrlCommand*)command
{
    NSString* userId = [command.arguments objectAtIndex:0];
    UIViewController *vc = [Zoom.sdk createVerificationVCWithDelegate:self];
    lastAction = @"enrollment";
    NSString* status = [self showEvalMethod];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)authenticate:(CDVInvokedUrlCommand*)command
{
    NSString* userId = [command.arguments objectAtIndex:0];
    UIViewController *vc = [Zoom.sdk createVerificationVCWithDelegate:self];
    lastAction = @"authenticate";
    NSString* status = [self showEvalMethod];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)verify:(CDVInvokedUrlCommand*)command
{
    UIViewController *vc = [Zoom.sdk createVerificationVCWithDelegate:self];
    lastAction = @"liveness";
    pendingCommand = command;
    //[Zoom.sdk setCustomization: zoomCustomization];
    zoomManagedSession = [[ZoomManagedSession alloc] initWithDelegate:self fromVC: self.viewController licenseKey:appToken zoomServerBaseURL:urlString mode:ZoomManagedSessionModeLiveness];
    
}


- (void)getVersion:(CDVInvokedUrlCommand*)command
{
    NSString* version = [Zoom.sdk version];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:version];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getUserEnrollmentStatus:(CDVInvokedUrlCommand*)command
{
    NSString* userId = [command.arguments objectAtIndex:0];
    NSString* status = [self showEvalMethod];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)getSdkStatus:(CDVInvokedUrlCommand*)command
{
    NSString* status = [self getSdkStatusString];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)isUserEnrolled:(CDVInvokedUrlCommand*)command
{
    NSString* status = [self showEvalMethod];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setPublicKey:(CDVInvokedUrlCommand*)command
{
    publicKey = [command.arguments objectAtIndex:0];
    NSString* status = @"Public Key Set";
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setServerUrl:(CDVInvokedUrlCommand*)command
{
    urlString =  [command.arguments objectAtIndex:0];
    NSString* status = @"Server url Set";
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setBrandingLogo:(CDVInvokedUrlCommand*)command
{
    zoomCustomization.guidanceCustomization.imageCustomization.introScreenBrandingImage = [UIImage imageNamed:@"custom_zoom_logo.png"];
    NSString* status = @"Custom logo enabled";
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setMainForeGroundColor:(CDVInvokedUrlCommand*)command
{
    zoomCustomization.guidanceCustomization.foregroundColor = [self colorFromHexString:[command.arguments objectAtIndex:0]];
    NSString* status  = @"Main Fore Ground Color Set";
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setMainBackGroundColor:(CDVInvokedUrlCommand*)command
{
    zoomCustomization.guidanceCustomization.backgroundColors = @[[self colorFromHexString:[command.arguments objectAtIndex:0]],[self colorFromHexString:[command.arguments objectAtIndex:0]]];
    NSString* status  = @"Main Back Ground Color Set";
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) onZoomManagedSessionCompleteWithStatus:(ZoomManagedSessionStatus)zoomManagedSessionStatus{
    NSDictionary* resultDict = @{
        @"successful": (zoomManagedSessionStatus == ZoomManagedSessionStatusSuccess ? @YES : @NO),
        @"status": [self convertZoomVerificationStatus:zoomManagedSessionStatus],
        @"livenessResult": [Zoom.sdk descriptionForManagedSessionStatusSubCode:zoomManagedSession.latestZoomManagedSessionStatusSubCode],
    };
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:pendingCommand.callbackId];
    pendingCommand = nil;
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
        case ZoomVerificationStatusFailedBecauseOfOSContextSwitch:
            return @"OSContextSwitch";
        case ZoomVerificationStatusFailedBecauseOfTimeout:
            return @"Timeout";
        case ZoomVerificationStatusFailedBecauseOfLowMemory:
            return @"LowMemory";
        case ZoomVerificationStatusFailedBecauseNoConnectionInDevMode:
            return @"NoConnectionInDevMode";
        case ZoomVerificationStatusFailedBecauseOfflineSessionsExceeded:
            return @"OfflineSessionsExceeded";
        case ZoomVerificationStatusFailedBecauseEncryptionKeyInvalid:
            return @"EncryptionKeyInvalid";
        default:
            return @"";
    }
}

- (NSString*)getSdkStatusString {
    switch ([Zoom.sdk getStatus]) {
        case ZoomSDKStatusNeverInitialized:
            return @"NeverInitialized";
        case ZoomSDKStatusInitialized:
            return @"Initialized";
        case ZoomSDKStatusNetworkIssues:
            return @"NetworkIssues";
        case ZoomSDKStatusVersionDeprecated:
            return @"VersionDeprecated";
        case ZoomSDKStatusOfflineSessionsExceeded:
            return @"OfflineSessionsExceeded";
            break;
        default:
            return @"";
    }
    return nil;
}

- (NSString*)showEvalMethod {
    
    return @"This option available only in full version. Please contact plugins@snapcommute.com for further details";
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)idCheck:(CDVInvokedUrlCommand*)command
{
    NSString* status = [self showEvalMethod];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)deleteEnrollment:(CDVInvokedUrlCommand*)command
{
    NSString* userId = [command.arguments objectAtIndex:0];
    NSString* status = [self showEvalMethod];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)auditTrail:(CDVInvokedUrlCommand*)command
{
    
    //NSString* status = [self showEvalMethod];
    
    //CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    //[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    if(zoomManagedSession.latestZoomSessionResult.faceMetrics.auditTrail != nil){
        auditImagesArray=[zoomManagedSession.latestZoomSessionResult.faceMetrics auditTrail];
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
        for (int i=0; i< [auditImagesArray count]; i++){
            [mutableDictionary setObject:toBase64([self processImage:auditImagesArray[i]  encodingType:0]) forKey:@(i).stringValue];
            NSLog(@"i %d",i);
        }
        NSLog(@"Dictionary: %@", [mutableDictionary description]);
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:mutableDictionary options:NSJSONReadingMutableContainers error:&err];
        NSLog(@"JsonObject: %@",[jsonData description]);
        NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        NSLog(@"myString: %@",myString);
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:mutableDictionary];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        NSString * status=@"No audit trail images";
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:status];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
    
}

- (void)setDefaultTheme:(CDVInvokedUrlCommand*)command
{
    
    NSString* status = [self showEvalMethod];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)setDarkTheme:(CDVInvokedUrlCommand*)command
{
    
    NSString* status = [self showEvalMethod];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)setMidnightTheme:(CDVInvokedUrlCommand*)command
{
    
    NSString* status = [self showEvalMethod];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)setSunsetTheme:(CDVInvokedUrlCommand*)command
{
    
    NSString* status = [self showEvalMethod];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}


- (NSData*)processImage:(UIImage*)image encodingType:(int)encodingType
{
    NSData* data = nil;
    
    switch (encodingType) {
        case 1:
            data = UIImagePNGRepresentation(image);
            break;
        case 0:
            data = UIImageJPEGRepresentation(image, 1.0);
            break;
        default:
            break;
    };
    
    return data;
}

@end

@interface ZoomManagedSession ()
@property (nonatomic, readwrite, setter=setZoomSessionResult:) id<ZoomSessionResult> _Nullable latestZoomSessionResult;

@property (nonatomic, readwrite, setter=setZoomManagedSessionStatusSubCode:) enum ZoomManagedSessionStatusSubCode latestZoomManagedSessionStatusSubCode;
@property (nonatomic, readwrite, setter=setFaceTecAPIResponseString:) NSString * _Nonnull latestFaceTecAPIResponseString;
- (void)onZoomSessionComplete;
@end


/*
 * Defines the callback that will be called to return the response from server calls.
 */
@protocol FaceTecManagedAPICallback <NSObject>
- (void)onResponse:(id)responseJSON;
@end


@interface ZoomManagedSessionFaceMapProcessor : NSObject <ZoomFaceMapProcessorDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
- (id _Nonnull)initWithManagedSession:(ZoomManagedSession * _Nonnull)zoomManagedSession;
- (id _Nonnull)initWithManagedSession:(ZoomManagedSession * _Nonnull)zoomManagedSession enrollmentIdentifier:(NSString * _Nullable)enrollmentIdentifier;
- (void)processZoomSessionResultWhileZoomWaits:(id<ZoomSessionResult>_Nonnull)zoomSessionResult zoomFaceMapResultCallback:(id<ZoomFaceMapResultCallback>_Nonnull)zoomFaceMapResultCallback;
@end



/*
 * Robust implementation of ZoomFaceMapProcessor
 *
 * In a production app, developers MUST create their own implementation of this class.
 *
 * This implementation uses the FaceTec Managed API, but can also be pointed at the
 * developer-deployed ZoOm Server REST SDK instance.
 *
 * As a final step before deploying a production application,
 * IT IS HIGHLY RECOMMENDED that developers close off the ZoOm Server REST SDK endpoints to the outside world
 * and instead proxy calls to the ZoOm Server REST SDK through their own secure web application/servers.
 */
@implementation ZoomManagedSessionFaceMapProcessor {
    // Keep track of the identifier of the FaceMap during Enrollment, Authentication, and Identity Check scenarios.
    NSString *enrollmentIdentifier;
    
    // Keep track of last ZoomFaceMapResultCallback so that developers can control the ZoOm UX after asynchronous API calls.
    id<ZoomFaceMapResultCallback> zoomFaceMapResultCallback;
    
    // Keep track of the ZoomManagedSession so that state can be updated as processing progresses.
    // Developer Note: Developer can do state tracking via other mechanisms if desired.
    ZoomManagedSession *zoomManagedSession;
}

- (id)initWithManagedSession:(ZoomManagedSession *)zoomManagedSession {
    if(self = [super init] ) {
        self->zoomManagedSession = zoomManagedSession;
    }
    return self;
}

- (id)initWithManagedSession:(ZoomManagedSession *)zoomManagedSession enrollmentIdentifier:(NSString *)enrollmentIdentifier {
    if(self = [super init] ) {
        self->zoomManagedSession = zoomManagedSession;
        self->enrollmentIdentifier = enrollmentIdentifier;
    }
    return self;
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
- (void)processZoomSessionResultWhileZoomWaits:(id<ZoomSessionResult> _Nonnull)zoomSessionResult zoomFaceMapResultCallback:(id<ZoomFaceMapResultCallback> _Nonnull)zoomFaceMapResultCallback {
    // Keep track of the latest result back in the ZoomManagedSession
    NSLog(@"1");
    [zoomManagedSession setZoomSessionResult:zoomSessionResult];
    NSLog(@"2");
    self->zoomFaceMapResultCallback = zoomFaceMapResultCallback;
    
    if(zoomSessionResult == nil) {
        [zoomManagedSession setZoomManagedSessionStatusSubCode:ZoomManagedSessionStatusSubCodeInternalUnsuccess];
        [zoomFaceMapResultCallback onFaceMapResultCancel];
        return;
    }
    
    if(zoomSessionResult.status != ZoomSessionStatusSessionCompletedSuccessfully) {
        NSLog(@"3");
        [self setUnsuccessSubCode:zoomSessionResult];
        [zoomFaceMapResultCallback onFaceMapResultCancel];
        return;
    }
    
    
    
    [zoomManagedSession setZoomManagedSessionStatusSubCode:ZoomManagedSessionStatusSubCodeTimeout];
    NSLog(@"4");
    if([zoomManagedSession mode] == ZoomManagedSessionModeLiveness) {
        NSLog(@"5");
        [self processLiveness:zoomSessionResult];
    }
    
    
}

- (void) onResponse:(id)responseJSON {
    NSLog(@"6");
    if([zoomManagedSession mode] == ZoomManagedSessionModeLiveness) {
        NSLog(@"7");
        [self processLivenessResponseAndGoToNextStep:responseJSON];
    }
    
}

/*
 * Process the Liveness Check
 *
 * This method of calling the FaceTec Managed API, as well as the string of helper functions and evaluation of the result
 * are fairly prescriptive.  The developer will most likely be completely changing these functions to conform the API calls
 * around the particulars of the developers own webservice/infrastructure/security practices.
 */
- (void) processLiveness:(id<ZoomSessionResult>_Nonnull)zoomSessionResult {
    // Call helper function that calls FaceTec Managed API (or ZoOm Server REST SDK) /liveness endpoint
    // Developer Note: For your production app, you will be calling your own webservice and NOT the FaceTec Managed API or ZoOm Server REST SDK directly.
    NSLog(@"8");
    [self callFaceTecManagedAPIForLiveness:zoomSessionResult faceTecManagedAPICallback:self];
}

/*
 * Handles calling the FaceTec Managed API (or ZoOm Server REST SDK) for Liveness Check.
 * Specific pieces handled:
 * 1.  Vanilla http request to API to process Liveness Check.
 * 2.  Setting License Key and Headers that are required by FaceTec Managed API
 * 3.  Detecting basic network failure and cancelling out if detected
 * 4.  Updating the progress bar via the ZoomFaceMapResultCallback.onProgress function
 * 5.  Gather the needed data in correct format -- i.e. the FaceMap, Session ID
 * 6.  Hand back response JSON to caller.
 */
- (void) callFaceTecManagedAPIForLiveness:(id<ZoomSessionResult>_Nonnull)zoomSessionResult faceTecManagedAPICallback:(id<FaceTecManagedAPICallback> _Nonnull)faceTecManagedAPICallback {
    NSLog(@"9");
    id<ZoomFaceBiometricMetrics> faceMetrics = zoomSessionResult.faceMetrics;
    NSLog(@"10");
    if(faceMetrics.faceMap == nil) {
        NSLog(@"11");
        [zoomManagedSession setZoomManagedSessionStatusSubCode:ZoomManagedSessionStatusSubCodeInternalUnsuccess];
        [zoomFaceMapResultCallback onFaceMapResultCancel];
        return;
    }
    
    NSString *zoomFaceMapBase64 = faceMetrics.faceMapBase64;
    
    [zoomManagedSession setZoomManagedSessionStatusSubCode:ZoomManagedSessionStatusSubCodeTimeout];
    
    NSMutableDictionary *parameters;
    parameters = @{
        @"faceMap": zoomFaceMapBase64,
        @"sessionId": zoomSessionResult.sessionId
    }.mutableCopy;
    NSLog(@"12");
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[zoomManagedSession.zoomServerBaseURL stringByAppendingString:@"/liveness"]]];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:zoomManagedSession.licenseKey forHTTPHeaderField:@"X-Device-License-Key"];
    [request addValue:[Zoom.sdk createZoomAPIUserAgentString:zoomSessionResult.sessionId] forHTTPHeaderField:@"User-Agent"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSLog(@"13");
    NSURLSession *apiSession = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration delegate:self delegateQueue:NSOperationQueue.mainQueue];
    NSLog(@"14");
    [self->zoomManagedSession setFaceTecAPIResponseString:@""];
    NSLog(@"15");
    id dataTask = [apiSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable serverData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"16");
        id responseJSON = [NSJSONSerialization JSONObjectWithData:serverData options:0 error:nil];
        [faceTecManagedAPICallback onResponse:responseJSON];
    }];
    NSLog(@"17");
    [dataTask resume];
}

/*
 * Evaluate a response from /liveness.
 * Check for Liveness Success, then check for Liveness Unsuccess (retry needed), else inform the caller that we should cancel.
 */
- (void) processLivenessResponseAndGoToNextStep:(id)responseJSON {
    // Dynamically set the success message.
    // In the developer application, this may not be needed if the developer wishes to show a generic success message in all modes
    // or if the developer only uses ZoOm in one mode.
    NSLog(@"18");
    NSLog(@"responseJSON",responseJSON);
    [ZoomCustomization setOverrideResultScreenSuccessMessage:@"Liveness Confirmed!"];
    
    if([(NSDictionary*)responseJSON objectForKey:@"data"] != nil &&
       [((NSDictionary*)responseJSON[@"data"])[@"livenessStatus"] intValue] == 0) {
        NSLog(@"19");
        [self->zoomManagedSession setZoomManagedSessionStatusSubCode:ZoomManagedSessionStatusSubCodeCompletedSuccessfully];
        [zoomFaceMapResultCallback onFaceMapResultSucceed];
    }
    else if([(NSDictionary*)responseJSON objectForKey:@"data"] != nil &&
            [((NSDictionary*)responseJSON[@"data"])[@"livenessStatus"] intValue] == 1) {
        NSLog(@"20");
        [zoomFaceMapResultCallback onFaceMapResultRetry];
    }
    else {
        NSLog(@"21");
        [zoomFaceMapResultCallback onFaceMapResultCancel];
    }
}

/*
 * Helper function to parse ZoomSessionResult and set more generic/friendly subcodes for consumers of ZoOm Managed Sessions.
 * Developers are encouraged to implement their own logic, logging, analytics here if desired.
 */
- (void) setUnsuccessSubCode:(id<ZoomSessionResult>_Nonnull)zoomSessionResult  {
    if(zoomSessionResult.status == ZoomSessionStatusUnknownInternalError) {
        [zoomManagedSession setZoomManagedSessionStatusSubCode: ZoomManagedSessionStatusSubCodeInternalUnsuccess];
    }
    else if(zoomSessionResult.status == ZoomSessionStatusTimeout) {
        NSLog(@"22");
        [zoomManagedSession setZoomManagedSessionStatusSubCode: ZoomManagedSessionStatusSubCodeTimeout];
    }
    else if(zoomSessionResult.status == ZoomSessionStatusNonProductionModeLicenseInvalid) {
        [zoomManagedSession setZoomManagedSessionStatusSubCode: ZoomManagedSessionStatusSubCodeNetworkError];
    }
    else if(zoomSessionResult.status == ZoomSessionStatusLockedOut) {
        [zoomManagedSession setZoomManagedSessionStatusSubCode: ZoomManagedSessionStatusSubCodeLockedOut];
    }
    else if(zoomSessionResult.status == ZoomSessionStatusMissingGuidanceImages) {
        [zoomManagedSession setZoomManagedSessionStatusSubCode: ZoomManagedSessionStatusSubCodeMissingGuidanceImages];
    }
    else if(zoomSessionResult.status == ZoomSessionStatusContextSwitch) {
        [zoomManagedSession setZoomManagedSessionStatusSubCode: ZoomManagedSessionStatusSubCodeContextSwitch];
    }
    else if(zoomSessionResult.status == ZoomSessionStatusCameraPermissionDenied || zoomSessionResult.status == ZoomSessionStatusCameraInitializationIssue) {
        [zoomManagedSession setZoomManagedSessionStatusSubCode: ZoomManagedSessionStatusSubCodeCameraError];
    }
    else if(zoomSessionResult.status == ZoomSessionStatusLandscapeModeNotAllowed || zoomSessionResult.status == ZoomSessionStatusReversePortraitNotAllowed) {
        [zoomManagedSession setZoomManagedSessionStatusSubCode: ZoomManagedSessionStatusSubCodePortraitModeRequired];
    }
    else if(zoomSessionResult.status == ZoomSessionStatusUserCancelled) {
        [zoomManagedSession setZoomManagedSessionStatusSubCode: ZoomManagedSessionStatusSubCodeUserCancelled];
    }
    else {
        NSLog(@"Unexpected value found: %li", (long)zoomSessionResult.status);
    }
}


- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    NSLog(@"23");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"24");
        float uploadProgress = (totalBytesSent / totalBytesExpectedToSend);
        if (self->zoomFaceMapResultCallback != nil) {
            NSLog(@"25");
            [self->zoomFaceMapResultCallback onFaceMapUploadProgress:uploadProgress];
        }
    });
}
@end

/*
 * The ZoOm Managed Session is a robust demonstration of wrapping the ZoOm Device SDK functionality,
 * handling different modes of operation (Liveness Check, Enrollment, Authentication, Identity Check),
 * a demonstration of how to handle result intermediates like the ZoOm 3D FaceMap, Audit Trail Images, and ID Scans.
 *
 * In a production app, developers MUST create their own implementation of this class.
 *
 * This implementation uses the FaceTec Managed API, but can also be pointed at the
 * developer-deployed ZoOm Server REST SDK instance.
 *
 * As a final step before deploying a production application,
 * IT IS HIGHLY RECOMMENDED that developers close off the ZoOm Server REST SDK endpoints to the outside world
 * and instead proxy calls to the ZoOm Server REST SDK through their own secure web application/servers.
 */
@implementation ZoomManagedSession {
    id<ZoomManagedSessionDelegate> _delegate;
    ZoomManagedSessionMode _mode;
    ZoomManagedSessionStatusSubCode _latestZoomManagedSessionStatusSubCode;
    id<ZoomSessionResult> _latestZoomSessionResult;
    NSString * _latestFaceTecAPIResponseString;
    NSString * licenseKey;
    NSString * zoomServerBaseURL;
}

// Must be set correctly in the constructor in order to use ZoOm
@synthesize licenseKey = _licenseKey;

// By default, this points at the FaceTec Managed API.
// After deploying your own instance of the ZoOm Server REST SDK, this can be pointed at the Base URL that is created by the setup guide.
// In a final, production application, developers will be proxying calls through their own secure web service.
@synthesize zoomServerBaseURL = _zoomServerBaseURL;

// The mode of operation -- Liveness Check, Enrollment, Authentication, Identity Check
@synthesize mode = _mode;

// Keep track of the latest status of the Managed Session progress.
// This is updated throughout each ZoOm journey and can be interrogated after the process to understand what happened.
@synthesize latestZoomManagedSessionStatusSubCode = _latestZoomManagedSessionStatusSubCode;

// Keep a reference to the latest ZoOm Session Result.
@synthesize latestZoomSessionResult = _latestZoomSessionResult;



// Keep track of latest response from FaceTec Managed API.
@synthesize latestFaceTecAPIResponseString = _latestFaceTecAPIResponseString;

// Used to call back to ZoomManagedSession caller with the overall result.
@synthesize delegate = _delegate;

/*
 * Check parameters, store local references, and kick off the ZoomSession!
 */
- (id)initWithDelegate:(id<ZoomManagedSessionDelegate>)delegate fromVC:(UIViewController *)fromVC licenseKey:(NSString * _Nonnull)licenseKey zoomServerBaseURL:(NSString * _Nonnull)zoomServerBaseURL mode:(enum ZoomManagedSessionMode)mode enrollmentIdentifier:(NSString *)enrollmentIdentifier {
    if(self = [super init] ) {
        _delegate = delegate;
        _mode = mode;
        _latestZoomManagedSessionStatusSubCode = ZoomManagedSessionStatusSubCodeNeverStarted;
        _latestFaceTecAPIResponseString = @"";
        _licenseKey = licenseKey;
        _zoomServerBaseURL = zoomServerBaseURL;
        
        // Bail if mode is liveness and enrollment identifier is passed to enforce appropriate calling of APIs
        if(mode == ZoomManagedSessionModeLiveness && enrollmentIdentifier != nil) {
            _latestZoomManagedSessionStatusSubCode = ZoomManagedSessionStatusSubCodeInvalidManagedSessionParameters;
            [delegate onZoomManagedSessionCompleteWithStatus: ZoomManagedSessionStatusUnsuccessCheckSubcode];
            return nil;
        }
        
        // Bail if mode is not liveness and enrollment identifier is not passed to enforce appropriate calling of APIs
        if(mode != ZoomManagedSessionModeLiveness && enrollmentIdentifier == nil) {
            _latestZoomManagedSessionStatusSubCode = ZoomManagedSessionStatusSubCodeInvalidManagedSessionParameters;
            [delegate onZoomManagedSessionCompleteWithStatus: ZoomManagedSessionStatusUnsuccessCheckSubcode];
            return nil;
        }
        
        // Bail if mode is not liveness and enrollment identifier is empty string to enforce appropriate calling of APIs
        if(mode != ZoomManagedSessionModeLiveness && enrollmentIdentifier != nil && [enrollmentIdentifier  isEqual: @""]) {
            _latestZoomManagedSessionStatusSubCode = ZoomManagedSessionStatusSubCodeInvalidManagedSessionParameters;
            [delegate onZoomManagedSessionCompleteWithStatus: ZoomManagedSessionStatusUnsuccessCheckSubcode];
            return nil;
        }
        
        UIViewController *sessionVC;
        
        id zoomManagedSessionFaceMapProcessor;
        
        switch (mode) {
            case ZoomManagedSessionModeLiveness:
                zoomManagedSessionFaceMapProcessor = [[ZoomManagedSessionFaceMapProcessor alloc] initWithManagedSession:self];
                sessionVC = [Zoom.sdk createSessionVCWithDelegate:self faceMapProcessorDelegate:zoomManagedSessionFaceMapProcessor];
                break;
            case ZoomManagedSessionModeEnroll:
                zoomManagedSessionFaceMapProcessor = [[ZoomManagedSessionFaceMapProcessor alloc] initWithManagedSession:self enrollmentIdentifier:enrollmentIdentifier];
                sessionVC = [Zoom.sdk createSessionVCWithDelegate:self faceMapProcessorDelegate:zoomManagedSessionFaceMapProcessor];
                break;
            case ZoomManagedSessionModeAuthenticate:
                zoomManagedSessionFaceMapProcessor = [[ZoomManagedSessionFaceMapProcessor alloc] initWithManagedSession:self enrollmentIdentifier:enrollmentIdentifier];
                sessionVC = [Zoom.sdk createSessionVCWithDelegate:self faceMapProcessorDelegate:zoomManagedSessionFaceMapProcessor];
                break;
            case ZoomManagedSessionModeIdentityCheck:
                zoomManagedSessionFaceMapProcessor = [[ZoomManagedSessionFaceMapProcessor alloc] initWithManagedSession:self enrollmentIdentifier:enrollmentIdentifier];
                
                sessionVC = [Zoom.sdk createSessionVCWithDelegate:self faceMapProcessorDelegate:zoomManagedSessionFaceMapProcessor];
                break;
                
        }
        
        // Finally, present the view controller
        [fromVC presentViewController:sessionVC animated:true completion:nil];
    }
    return self;
}

- (id)initWithDelegate:(id<ZoomManagedSessionDelegate>)delegate fromVC:(UIViewController *)fromVC licenseKey:(NSString * _Nonnull)licenseKey zoomServerBaseURL:(NSString * _Nonnull)zoomServerBaseURL mode:(enum ZoomManagedSessionMode)mode  {
    return [self initWithDelegate:delegate fromVC:fromVC licenseKey:licenseKey zoomServerBaseURL:zoomServerBaseURL mode:mode enrollmentIdentifier:nil];
}

// The onZoomSessionComplete Delegate is a required argument to starting a ZoomSession.
// This function is called at the very end of a ZoomSession capture.
// It has no arguments/data passed back to the developer because the developer has already seen/handled all results
// inside the ZoomFaceMapProcessor or ZoomIDScanProcessor.
- (void)onZoomSessionComplete {
    if(_latestZoomManagedSessionStatusSubCode == ZoomManagedSessionStatusSubCodeCompletedSuccessfully) {
        [_delegate onZoomManagedSessionCompleteWithStatus:ZoomManagedSessionStatusSuccess];
    }
    else {
        [_delegate onZoomManagedSessionCompleteWithStatus:ZoomManagedSessionStatusUnsuccessCheckSubcode];
    }
}

@end
