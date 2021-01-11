# cordova-queue-it

Cordova plugin for integration Queue-it's virtual waiting room into Cordova/Ionic apps.

## Sample app

A sample app project to try out functionality of the library can be found in the example directory.

## Installation

Before starting please download the whitepaper **Mobile App Integration** from the Go Queue-it Platform. This whitepaper contains the needed information to perform
a successful integration.

You can use the [Cordova CLI](https://cordova.apache.org/docs/en/4.0.0/guide_cli_index.md.html) to install the plugin:
```bash
cordova plugin add https://github.com/queueit/cordova-queue-it.git
```

This plugin adds a new Android Activity so you might need to add it to your manifest.

```xml
<activity android:name="com.queue_it.androidsdk.QueueActivity"/>
```

## Usage

To protect parts of your application you'll need to make a `QueueIt.run` call and wait for it's result in a callback.  
The callback is called with different states as you can see in the example:

```javascript
//This function would make the user enter a queue and it uses a callback to handle the user's state.
//When the user gets his turn he may get a QueueITToken which signifies the user's session.
//An error would be sent to the callback if:
// 1) Queue-it's servers can't be reached (connectivity issue).
// 2) SSL connection error if custom queue domain is used having an invalid certificate.
// 3) Client receives HTTP 4xx response.
// In all these cases is most likely a misconfiguration of the queue settings:
// Invalid customer ID, event alias ID or cname setting on queue (GO Queue-it portal -> event settings).
function enqueue(){
    var customerId = "myCustomerId";
    var waitingRoomId = "waitingRoom";
    var layoutName = null;
    var language = null;
    var clearCache = false; // Use `true` here if you want to reset his position.

    QueueIt.run(customerId, waitingRoomId, layoutName, language, clearCache, function(result){
        console.log("QueueIt run result", JSON.stringify(result));
        if(result.Error){
            console.warn("Errored out: " + result.Message);
            return;
        }
        switch (result.State){
            case "Passed":
                // At this point the Queue-it webview is closed and the previous screen is visible
                console.log("User got his turn with token: " + result.QueueITToken);
                break;
            case "Disabled":
                console.log("Waiting room is disabled");
                break;
            case "Unavailable":
                console.log("Waiting room is not available");
                break;
            case "ViewWillOpen":
                console.log("Waiting room WebView is being opened");
                break;
            case "CloseClicked":
                console.log("User clicked on a `queueit://close` link, so webview was closed")
                break;
        }
    })
}
```

As the App developer you must manage the state (whether user was previously queued up or not) inside your app's storage. 
After you get the callback call with `State: Passed`, the app must remember this, possibly with a date/time expiration.  
When the user goes to another page/screen - you check his state,
  and only call run in the case where the user was not previously queued up.
When the user clicks back, the same check needs to be done.

![App Integration Flow](https://github.com/queueit/react-native-queue-it/blob/master/App%20integration%20flow.PNG "App Integration Flow")

## License

MIT
