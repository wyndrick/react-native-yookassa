import { NativeModules, Platform } from 'react-native';
let YookassaNative 
if (Platform.OS !== 'web') {
  YookassaNative = NativeModules.Yookassa
} else {
  var shopId
  YookassaNative = {
    initialize:(_shopId, token, clientId)=> {
      shopId = _shopId
    },
    tokenization:(title, desc, summ, paymentType, savePaymentMethod, testParameters) => {},
    openWidget:(confirmationToken, returnUrl, elementId, onSuccess, onFail) => {
      const checkout = new window.YooMoneyCheckoutWidget({
        confirmation_token: confirmationToken, //Токен, который перед проведением оплаты нужно получить от ЮKassa
        return_url: returnUrl, //Ссылка на страницу завершения оплаты
        error_callback(error) {
          console.log("Обработка ошибок инициализации", error)
        }
      });
      checkout.render(elementId)
      .then((result) => {
        console.log("payment-form", result)
        onSuccess(result)
      })
      .catch(err => {
        console.log("payment-form", err)
        onFail(err)
      })
    }
  }
}

/**
 * Enum for PaymentType.
 * @readonly
 * @enum {string}
 */
const PaymentType = Object.freeze({
  SBERBANK : "SBERBANK",
  BANK_CARD : "BANK_CARD",
  GOOGLE_PAY : "GOOGLE_PAY",
  YOO_MONEY : "YOO_MONEY",
});

const SavePaymentMethod = Object.freeze({
  ON : "ON",
  OFF : "OFF",
  USER_SELECTS : "USER_SELECTS",
});

const ResultStatus = Object.freeze({
  RESULT_OK : "RESULT_OK",
  RESULT_CANCELED : "RESULT_CANCELED",
  RESULT_ERROR : "RESULT_ERROR",
});

class Yookassa {
  static paymentTypes = PaymentType
  static savePaymentMethods = SavePaymentMethod
  static initialize = (shopId, token, clientId = null) => {
    YookassaNative.initialize(shopId, token, clientId);
  }
  static openWidget = (confirmationToken, returnUrl, elementId, onSuccess, onFail) => {
    YookassaNative.openWidget(confirmationToken, returnUrl, onSuccess, onFail);
  }
  static tokenization = (title, desc, summ, paymentType, savePaymentMethod, testParameters) => {
    console.log("YOOKASSA tokenization start = ")
    return new Promise((resolve, reject) => {
      YookassaNative.tokenization(title, desc, summ, paymentType, savePaymentMethod, testParameters, (result) => {
        console.log("YOOKASSA RESULT = ", result)
        switch(result.status) {
          case ResultStatus.RESULT_OK:
            resolve(result)
            break;
          case ResultStatus.RESULT_CANCELED:
            resolve(result)
            break;
          case ResultStatus.RESULT_ERROR:
            reject(result)
            break;
        }
      })
    });
  }
}


export default Yookassa;
