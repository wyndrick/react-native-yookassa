import { NativeModules } from 'react-native';

const { Yookassa: YookassaNative } = NativeModules;

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
  static init = (shopId, token, clientId = null) => {
    YookassaNative.init(shopId, token, clientId);
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
