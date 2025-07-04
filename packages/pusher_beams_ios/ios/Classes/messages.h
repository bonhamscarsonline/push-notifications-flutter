// Autogenerated from Pigeon (v1.0.14), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import <Foundation/Foundation.h>
@protocol FlutterBinaryMessenger;
@protocol FlutterMessageCodec;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

@class BeamsAuthProvider;

@interface BeamsAuthProvider : NSObject
@property(nonatomic, copy, nullable) NSString * authUrl;
@property(nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> * headers;
@property(nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> * queryParams;
@property(nonatomic, copy, nullable) NSString * credentials;
@end

/// The codec used by PusherBeamsApi.
NSObject<FlutterMessageCodec> *PusherBeamsApiGetCodec(void);

@protocol PusherBeamsApi
- (void)startInstanceId:(NSString *)instanceId error:(FlutterError *_Nullable *_Nonnull)error;
- (void)getInitialMessageWithCompletion:(void(^)(NSDictionary<NSString *, NSObject *> *_Nullable, FlutterError *_Nullable))completion;
- (void)addDeviceInterestInterest:(NSString *)interest error:(FlutterError *_Nullable *_Nonnull)error;
- (void)removeDeviceInterestInterest:(NSString *)interest error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable NSArray<NSString *> *)getDeviceInterestsWithError:(FlutterError *_Nullable *_Nonnull)error;
- (void)setDeviceInterestsInterests:(NSArray<NSString *> *)interests error:(FlutterError *_Nullable *_Nonnull)error;
- (void)clearDeviceInterestsWithError:(FlutterError *_Nullable *_Nonnull)error;
- (void)onInterestChangesCallbackId:(NSString *)callbackId error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setUserIdUserId:(NSString *)userId provider:(BeamsAuthProvider *)provider callbackId:(NSString *)callbackId error:(FlutterError *_Nullable *_Nonnull)error;
- (void)clearAllStateWithError:(FlutterError *_Nullable *_Nonnull)error;
- (void)onMessageReceivedInTheForegroundCallbackId:(NSString *)callbackId error:(FlutterError *_Nullable *_Nonnull)error;
- (void)onNotificationTappedCallbackId:(NSString *)callbackId error:(FlutterError *_Nullable *_Nonnull)error;
- (void)stopWithError:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void PusherBeamsApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<PusherBeamsApi> *_Nullable api);

/// The codec used by CallbackHandlerApi.
NSObject<FlutterMessageCodec> *CallbackHandlerApiGetCodec(void);

@interface CallbackHandlerApi : NSObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
- (void)handleCallbackCallbackId:(NSString *)callbackId callbackName:(NSString *)callbackName args:(NSArray *)args completion:(void(^)(NSError *_Nullable))completion;
@end
NS_ASSUME_NONNULL_END