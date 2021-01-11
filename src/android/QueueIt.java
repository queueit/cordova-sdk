package com.queueit;

import android.app.Activity;
import android.os.Handler;

import com.queue_it.androidsdk.Error;
import com.queue_it.androidsdk.QueueITEngine;
import com.queue_it.androidsdk.QueueITException;
import com.queue_it.androidsdk.QueueListener;
import com.queue_it.androidsdk.QueuePassedInfo;
import com.queue_it.androidsdk.QueueService;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

enum EnqueueResultState {
    Passed, Disabled, Unavailable, ViewWillOpen, CloseClicked
}

public class QueueIt extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        switch (action) {
            case "runAsync":
                return runAsync(data, callbackContext);
            case "enableTesting":
                return enableTesting(data);
        }
        return false;
    }

    private PluginResult getRunResultObject(String queueItToken, EnqueueResultState state) {
        JSONObject obj = new JSONObject();
        try {
            obj.put("QueueITToken", queueItToken);
            obj.put("State", state.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        PluginResult result = new PluginResult(PluginResult.Status.OK, obj);
        result.setKeepCallback(true);
        return result;
    }

    private JSONObject getErrorObject(Error err, String errorMessage) {
        JSONObject obj = new JSONObject();
        try {
            obj.put("Error", err.toString());
            obj.put("Message", errorMessage);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return obj;
    }

    private boolean enableTesting(JSONArray data) throws JSONException {
        QueueService.IsTest = data.getBoolean(0);
        return true;
    }

    private boolean runAsync(JSONArray data, CallbackContext callbackContext) throws JSONException {
        Activity context = this.cordova.getActivity();
        String customerId = data.getString(0);
        String eventOrAliasId = data.getString(1);
        String layoutName = data.getString(2);
        String language = data.getString(3);
        boolean resetCache = data.getBoolean(4);
        Handler handler = new Handler(context.getMainLooper());
        QueueListener listener = new QueueListener() {
            @Override
            protected void onQueuePassed(QueuePassedInfo queuePassedInfo) {
                handler.post(() -> {
                    if (queuePassedInfo == null) {
                        callbackContext.sendPluginResult(getRunResultObject("", EnqueueResultState.Passed));
                    } else {
                        callbackContext.sendPluginResult(getRunResultObject(queuePassedInfo.getQueueItToken(), EnqueueResultState.Passed));
                    }
                });
            }

            @Override
            protected void onQueueViewWillOpen() {
                callbackContext.sendPluginResult(getRunResultObject(null, EnqueueResultState.ViewWillOpen));
            }

            @Override
            protected void onQueueDisabled() {
                callbackContext.sendPluginResult(getRunResultObject(null, EnqueueResultState.Disabled));
            }

            @Override
            protected void onQueueItUnavailable() {
                callbackContext.sendPluginResult(getRunResultObject(null, EnqueueResultState.Unavailable));
            }

            @Override
            protected void onError(Error error, String errorMessage) {
                callbackContext.error(getErrorObject(error, errorMessage));
            }

            @Override
            protected void onWebViewClosed() {
                callbackContext.sendPluginResult(getRunResultObject(null, EnqueueResultState.CloseClicked));
            }
        };
        context.runOnUiThread(() -> {
            QueueITEngine engine = new QueueITEngine(context, customerId, eventOrAliasId, layoutName, language, listener);
            try {
                engine.run(context, resetCache);
            } catch (QueueITException e) {
                e.printStackTrace();
            }
        });

        return true;
    }
}
