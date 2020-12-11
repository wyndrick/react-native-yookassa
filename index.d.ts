/**
 * typescript definition
 * @author wyndrick
 */
declare module "react-native-yookassa"{
    import * as React from 'react';
    import * as ReactNative from "react-native";
    import {TextStyle,StyleProp,ViewStyle} from "react-native";
    export interface YookassaOptions {
    }

    export interface YookassaProps extends YookassaOptions, ReactNative.ViewProperties {

    }

    export interface PaymentType {
        SBERBANK : string,
        BANK_CARD : string,
        GOOGLE_PAY : string,
        YOO_MONEY : string,
    }

    export interface SavePaymentMethod {
        ON : string,
        OFF : string,
        USER_SELECTS : string,
    }
    export interface ITokenizationResult {
        paymentToken: string;
        paymentMethodType: string;
        status: "RESULT_OK"|"RESULT_CANCELED"|"RESULT_ERROR";
    }
    export default class Yookassa extends React.Component<YookassaProps> {
        static init:(shopId:string, token:string, clientId:string)=>any;
        static tokenization:(
            title:string, 
            desc:string, 
            summ:int, 
            paymentType:PaymentType.SBERBANK|PaymentType.BANK_CARD|PaymentType.GOOGLE_PAY|PaymentType.YOO_MONEY,
            savePaymentMethods:SavePaymentMethod.ON|SavePaymentMethod.OFF|SavePaymentMethod.USER_SELECTS,
            testParameters:{
                showLogs:boolean; //(Boolean) - включить отображение логов SDK. Все логи начинаются с тега 'YooKassa.SDK'
                googlePayTestEnvironment:boolean ; //(Boolean) - использовать тестовую среду Google Pay
                completeWithError:boolean; // (Boolean) - токенизация всегда возвращает ошибку;
                paymentAuthPassed:boolean; // (Boolean) - пользователь всегда авторизован;
                linkedCardsCount:number; // (Int) - количество карт, привязанных к кошельку пользователя;
                serviceFee:number; // (Int) - количество карт, привязанных к кошельку пользователя;
            }
        )=>Promise<ITokenizationResult>;
        static paymentTypes:PaymentType;
        static savePaymentMethods:SavePaymentMethod;
    }
}
