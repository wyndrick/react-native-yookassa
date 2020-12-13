//
//  Yookassa.swift
//  react-native-yookassa
//
//  Created by User on 12.12.2020.
//

import Foundation
import YooKassaPayments
import YooKassaPaymentsApi

@objc(Yookassa)
class Yookassa: UIViewController {

    private var callback: RCTResponseSenderBlock? = nil;
    private var tokenizationView: UIViewController? = nil;
    var shopId:String? = nil
    var shopToken:String? = nil
    var clienId:String? = nil

    @objc
    func initialize(
        _ shopId:String,
        shopToken:String,
        clienId:String
    ) {
        self.shopId = shopId;
        self.shopToken = shopToken;
        self.clienId = clienId;
    }

    @objc
    func tokenization(_ title: String,
                 withDesc desc: String,
                 withSumm amount: NSNumber,
                 withPaymentType paymentType: String,
                 withSavePaymentMethods savePaymentMethods: String,
                 withTestParameters testParameters: NSDictionary?,
                 withCallback callback: @escaping RCTResponseSenderBlock) -> Void {

        self.callback = callback;
        var paymentMethodType:PaymentMethodTypes!;
        switch(paymentType) {
        case "SBERBANK":
            paymentMethodType = PaymentMethodTypes.sberbank // - ЮMoney (платежи из кошелька или привязанной картой)
            break;
        case "BANK_CARD":
            paymentMethodType = PaymentMethodTypes.bankCard; // - банковская карта (карты можно сканировать)
            break;
        case "APPLE_PAY":
            paymentMethodType = PaymentMethodTypes.applePay; // - Сбербанк Онлайн (с подтверждением по смс)
            break;
        case "YOO_MONEY":
            paymentMethodType = PaymentMethodTypes.yooMoney; // - Apple Pay
            break;
        default:
            paymentMethodType = PaymentMethodTypes.bankCard;
            break
        }
        var selectedSavePaymentMethod = SavePaymentMethod.off;
        switch(savePaymentMethods) {
        case "OFF":
            selectedSavePaymentMethod = SavePaymentMethod.off;
            break;
        case "ON":
            selectedSavePaymentMethod = SavePaymentMethod.on;
            break;
        case "USER_SELECTS":
            selectedSavePaymentMethod = SavePaymentMethod.userSelects;
            break;
        default:
            selectedSavePaymentMethod = .userSelects;
            break
        }
//        title:string,
//        desc:string,
//        summ:int,
//        paymentType:PaymentType.SBERBANK|PaymentType.BANK_CARD|PaymentType.GOOGLE_PAY|PaymentType.YOO_MONEY,
//        savePaymentMethods:SavePaymentMethod.ON|SavePaymentMethod.OFF|SavePaymentMethod.USER_SELECTS,
//        testParameters:{
//            showLogs:boolean; //(Boolean) - включить отображение логов SDK. Все логи начинаются с тега 'YooKassa.SDK'
//            googlePayTestEnvironment:boolean ; //(Boolean) - использовать тестовую среду Google Pay
//            completeWithError:boolean; // (Boolean) - токенизация всегда возвращает ошибку;
//            paymentAuthPassed:boolean; // (Boolean) - пользователь всегда авторизован;
//            linkedCardsCount:number; // (Int) - количество карт, привязанных к кошельку пользователя;
//            serviceFee:number; // (Int) - количество карт, привязанных к кошельку пользователя;
//        }

        let newAmount = Amount(value: Decimal(amount.doubleValue), currency: .rub)

        var testModeSettings: TestModeSettings? = nil
        if let test = testParameters {
//            let showLogs = test["showLogs"] as? Bool;
            let linkedCardsCount = test["linkedCardsCount"] as? NSNumber;
            let paymentAuthPassed = test["paymentAuthPassed"] as? Bool;
            let enablePaymentError = test["enablePaymentError"] as? Bool;
            testModeSettings = TestModeSettings(paymentAuthorizationPassed: paymentAuthPassed ?? false,
                             cardsCount: linkedCardsCount?.intValue ?? 1,
                             charge: newAmount,
                             enablePaymentError: enablePaymentError ?? false)
        }
        if let clientApplicationKey = shopToken,
           let moneyAuthClientId = clienId {
            let customizationSettings = CustomizationSettings(mainScheme: UIColor(red: 255/255.0, green: 51/255.0, blue: 88/255.0, alpha: 1))
            let tokenizationSettings = TokenizationSettings(paymentMethodTypes: paymentMethodType)
            let tokenizationModuleInputData = TokenizationModuleInputData(
                clientApplicationKey: clientApplicationKey,
                shopName: title,
                purchaseDescription: desc,
                amount: newAmount,
                gatewayId: nil,
                tokenizationSettings: tokenizationSettings,
                testModeSettings: testModeSettings,
                cardScanning: nil,
                applePayMerchantIdentifier: nil,
                returnUrl: nil,
                isLoggingEnabled: true,
                userPhoneNumber: nil,
                customizationSettings: customizationSettings,
                savePaymentMethod: selectedSavePaymentMethod,
                moneyAuthClientId: moneyAuthClientId
            )

            let inputData: TokenizationFlow = .tokenization(tokenizationModuleInputData)

            DispatchQueue.main.async {
                self.tokenizationView = TokenizationAssembly.makeModule(inputData: inputData, moduleOutput: self)
                //present(viewController, animated: true, completion: nil)
//                if let delegate = UIApplication.shared.delegate {
//                    if (self.tokenizationView != nil) {
//                        delegate.window??.rootViewController?.present(self.tokenizationView!, animated: true, completion: nil)
//                    }
//                }
                
                var topViewController = UIApplication.shared.keyWindow?.rootViewController
                while ((topViewController?.presentedViewController) != nil) {
                    topViewController = topViewController?.presentedViewController;
                }
                if let root = topViewController {
                    if (self.tokenizationView != nil) {
                        root.present(self.tokenizationView!, animated: true, completion: nil)
                    }
                }
//                UIApplication.shared.keyWindow!.makeKeyAndVisible()
//                let root = UIApplication.shared.keyWindow!.rootViewController
//                root?.present(self, animated: true, completion: nil)
//
//                if (self.tokenizationView != nil) {
//                    self.present(self.tokenizationView!, animated: true, completion: nil)
//                }

            }
        }
    }

    @objc
    func finish() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)

            let root = UIApplication.shared.keyWindow?.rootViewController
            root?.dismiss(animated: true, completion: nil)
        }
    }

    @objc
    static func requiresMainQueueSetup() -> Bool {
      return true
    }

}

extension Yookassa: TokenizationModuleOutput {
    func tokenizationModule(_ module: TokenizationModuleInput,
                          didTokenize token: Tokens,
                          paymentMethodType: PaymentMethodType) {


        if (callback != nil) {
            let result: NSMutableDictionary = [:];
            result["status"] = "RESULT_OK";
            result["paymentToken"] = token.paymentToken;
            result["paymentMethodType"] = paymentMethodType.rawValue;
            callback!([result]);
        }

    }

    func didSuccessfullyPassedCardSec(on module: TokenizationModuleInput) {
        self.finish()
    }

    func needsConfirmPayment(requestUrl: String) {
        (self.tokenizationView! as! TokenizationModuleInput).start3dsProcess(requestUrl: requestUrl)
    }

    func didFinish(on module: TokenizationModuleInput,
                   with error: YooKassaPaymentsError?) {

        self.finish()

        if (callback != nil) {
            let result: NSMutableDictionary = [:];
            result["status"] = (error != nil) ? "RESULT_ERROR" : "RESULT_CANCELED";
            result["message"] = error?.localizedDescription ?? nil;
            callback!([result]);
        }
    }
}
