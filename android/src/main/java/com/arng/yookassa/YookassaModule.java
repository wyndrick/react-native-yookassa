package com.arng.yookassa;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.preference.PreferenceManager;
import android.util.Log;

import androidx.core.app.ActivityCompat;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;

import ru.yoo.sdk.kassa.payments.Amount;
import ru.yoo.sdk.kassa.payments.Checkout;
import ru.yoo.sdk.kassa.payments.GooglePayParameters;
import ru.yoo.sdk.kassa.payments.PaymentMethodType;
import ru.yoo.sdk.kassa.payments.PaymentParameters;
import ru.yoo.sdk.kassa.payments.SavePaymentMethod;
import ru.yoo.sdk.kassa.payments.MockConfiguration;
import ru.yoo.sdk.kassa.payments.SavedBankCardPaymentParameters;
import ru.yoo.sdk.kassa.payments.TestParameters;
import ru.yoo.sdk.kassa.payments.TokenizationResult;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.Collections;
import java.util.Currency;
import java.util.Set;

import javax.annotation.Nullable;

public class YookassaModule extends ReactContextBaseJavaModule implements ActivityEventListener {

    private final ReactApplicationContext reactContext;

    private String SHOP_ID;
    private String SHOP_TOKEN;
    private @Nullable String CLIENT_ID;
    private String SHOP_NAME;
    private String SHOP_DESCRIPTION;

    private Double PAYMENT_AMOUNT;
    private Currency PAYMENT_CURRENCY;
    private ReadableArray PAYMENT_TYPES_ARRAY;
    int REQUEST_CODE_TOKENIZE; // результат статуса токена на оплату
    Callback callback;

    @ReactMethod
    public void initialize(String SHOP_ID, String SHOP_TOKEN, @Nullable String CLIENT_ID) {
        this.SHOP_ID = SHOP_ID;
        this.SHOP_TOKEN = SHOP_TOKEN;
        this.CLIENT_ID = CLIENT_ID;
    }
    public YookassaModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        reactContext.addActivityEventListener(this);
    }

    @Override
    public String getName() {
        return "Yookassa";
    }


    @ReactMethod
    public void tokenization(String title, String desc, Integer summ, String paymentType, String savePaymentMethod,  @Nullable ReadableMap testParameters, Callback callback) {

        Context context = getReactApplicationContext();
        this.callback = callback;
        Set<PaymentMethodType> paymentMethodType = Collections.singleton(PaymentMethodType.SBERBANK);
        switch(paymentType) {
            case "SBERBANK":
                paymentMethodType = Collections.singleton(PaymentMethodType.SBERBANK);
                break;
            case "BANK_CARD":
                paymentMethodType = Collections.singleton(PaymentMethodType.BANK_CARD);
                break;
            case "GOOGLE_PAY":
                paymentMethodType = Collections.singleton(PaymentMethodType.GOOGLE_PAY);
                break;
            case "YOO_MONEY":
                paymentMethodType = Collections.singleton(PaymentMethodType.YOO_MONEY);
                break;
        }
        SavePaymentMethod selectedSavePaymentMethod = SavePaymentMethod.OFF;
        switch(savePaymentMethod) {
            case "OFF":
                selectedSavePaymentMethod = SavePaymentMethod.OFF;
                break;
            case "ON":
                selectedSavePaymentMethod = SavePaymentMethod.ON;
                break;
            case "USER_SELECTS":
                selectedSavePaymentMethod = SavePaymentMethod.USER_SELECTS;
                break;
        }

        PaymentParameters parameters = new PaymentParameters(
            new Amount(BigDecimal.valueOf(summ), Currency.getInstance("RUB")),
            title,
            desc,
            SHOP_TOKEN,
            SHOP_ID,
            selectedSavePaymentMethod,
            paymentMethodType,
            null,
            null,
            null,
            new GooglePayParameters(),
            CLIENT_ID
        );

        TestParameters tParameters = null;
        if (testParameters != null) {
            Boolean showLogs = true; //(Boolean) - включить отображение логов SDK. Все логи начинаются с тега 'YooKassa.SDK'
            Boolean googlePayTestEnvironment = false; //(Boolean) - использовать тестовую среду Google Pay
            Boolean completeWithError = false; // (Boolean) - токенизация всегда возвращает ошибку;
            Boolean paymentAuthPassed = false; // (Boolean) - пользователь всегда авторизован;
            Integer linkedCardsCount = 1; // (Int) - количество карт, привязанных к кошельку пользователя;
            Amount serviceFee = new Amount(BigDecimal.valueOf(0), Currency.getInstance("RUB")); // (Amount) - комиссия, которая будет отображена на контракте;

            if (testParameters.hasKey("showLogs")) {
                showLogs = testParameters.getBoolean("showLogs");
            }
            if (testParameters.hasKey("googlePayTestEnvironment")) {
                googlePayTestEnvironment = testParameters.getBoolean("googlePayTestEnvironment");
            }
            if (testParameters.hasKey("completeWithError")) {
                completeWithError = testParameters.getBoolean("completeWithError");
            }
            if (testParameters.hasKey("paymentAuthPassed")) {
                paymentAuthPassed = testParameters.getBoolean("paymentAuthPassed");
            }
            if (testParameters.hasKey("linkedCardsCount")) {
                linkedCardsCount = testParameters.getInt("linkedCardsCount");
            }
            if (testParameters.hasKey("serviceFee")) {
                serviceFee = new Amount(BigDecimal.valueOf(testParameters.getInt("serviceFee")), Currency.getInstance("RUB"));
            }
            tParameters = new TestParameters(showLogs, googlePayTestEnvironment,
                new MockConfiguration(completeWithError, paymentAuthPassed, linkedCardsCount, serviceFee));
        }
        try {

//        UiParameters uiParameters = new UiParameters(true, new ColorScheme(Color.rgb(183, 134, 252)));
        Intent intent = Checkout.createTokenizeIntent(reactContext, parameters, tParameters);
        getCurrentActivity().startActivityForResult(intent, REQUEST_CODE_TOKENIZE);

        } catch (Exception ex) {
            WritableMap errorMap = new WritableNativeMap();
            errorMap.putString("status", "RESULT_ERROR");
            errorMap.putString("message", ex.getLocalizedMessage());
            callback.invoke(errorMap);
        }
    }



    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_TOKENIZE) {
            switch (resultCode) {
                case Activity.RESULT_OK:
                    // successful tokenization
                    TokenizationResult result = Checkout.createTokenizationResult(data);
                    WritableMap resultMap = new WritableNativeMap();
                    resultMap.putString("status", "RESULT_OK");
                    resultMap.putString("paymentToken", result.paymentToken);
                    resultMap.putString("paymentMethodType", result.paymentMethodType.toString());
                    callback.invoke(resultMap);
                    break;
                case Activity.RESULT_CANCELED:
                    // user canceled tokenization
                    WritableMap errorMap = new WritableNativeMap();
                    errorMap.putString("status", "RESULT_CANCELED");
                    callback.invoke(errorMap);
                    break;
            }
        }
    }

    @Override
    public void onNewIntent(Intent intent) {
    }
}
