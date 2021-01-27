import { NativeModules, Platform } from 'react-native';
let YookassaNative 
if (Platform.OS !== 'web') {
  console.log(widget)
  YookassaNative = NativeModules.Yookassa
  
} else {
  var shopId
  YookassaNative = {
    initialize:(_shopId, token, clientId)=> {
      shopId = _shopId
    },
    tokenization:(title, desc, summ, paymentType, savePaymentMethod, testParameters) => {
      const checkout = YooMoneyCheckoutUI(shopId, {
        language: 'ru',
        domSelector: 'body',
        amount: summ
      });

      checkout.open()
      try {
        checkout.on('yc_error', response => {
          console.log("yc_error", response)
          /*
            {
                status: 'error',
                error: {
                    type: 'validation_error',
                    message: undefined,
                    status_code: 400,
                    code: undefined,
                    params: [
                        {
                            code: 'invalid_number',
                            message: 'Неверный номер карты'
                        },
                        {
                            code: 'invalid_expiry_month',
                            message: 'Невалидное значение месяца'
                        }
                    ]
                }
            }
          */
        });
        checkout.on('yc_success', response => {
          console.log("yc_success", response)
          checkout.chargeSuccessful();
          /*
          {
              status: 'success',
              data: {
                  message: 'Токен для оплаты создан',
                  status_code: 200,
                  type: 'payment_token_created',
                  response: {
                      paymentToken: 'eyJlbmNyeXB0ZWRNZXNzYWdlIjoiWlc1amNubHdkR1ZrVFdWemMyRm5aUT09IiwiZXBoZW1lcmFsUHVibGljS2V5IjoiWlhCb1pXMWxjbUZzVUhWaWJHbGpTMlY1IiwidGFnIjoiYzJsbmJtRjBkWEpsIn0K'
                  }
              }
          }
          */
        });
      } catch (err) {
        console.log(err)
      }
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
    console.log(YookassaNative)
    YookassaNative.initialize(shopId, token, clientId);
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
