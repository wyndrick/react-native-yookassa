#import "React/RCTBridgeModule.h"
#import "React/RCTUtils.h"

@interface RCT_EXTERN_MODULE(Yookassa, UIViewController)

RCT_EXTERN_METHOD(initialize:
                  (NSString)shopId
                  shopToken: (NSString)shopToken
                  clienId: (NSString)clienId
                  
)
    
RCT_EXTERN_METHOD(tokenization:
                  (NSString)title
                  withDesc: (NSString)desc
                  withSumm: (nonnull NSNumber)amount
                  withPaymentType: (NSString)paymentType
                  withSavePaymentMethods: (NSString)savePaymentMethods
                  withTestParameters: (nullable NSDictionary)testParameters
                  withCallback: (RCTResponseSenderBlock)callback
)


RCT_EXTERN_METHOD(finish)
@end
