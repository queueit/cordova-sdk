/* eslint no-undef: "off" */

document.addEventListener('deviceready', function onDeviceReady () {
    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');
}, false);

// This function would make the user enter a queue and it uses a callback to handle the user's state.
// When the user gets his turn he may get a QueueITToken which signifies the user's session.
// An error would be sent to the callback if:
// 1) Queue-it's servers can't be reached (connectivity issue).
// 2) SSL connection error if custom queue domain is used having an invalid certificate.
// 3) Client receives HTTP 4xx response.
// In all these cases is most likely a misconfiguration of the queue settings:
// Invalid customer ID, event alias ID or cname setting on queue (GO Queue-it portal -> event settings).
function enqueue () {
    var customerId = 'customer';
    var waitingRoomId = 'eventOrAlias';
    var layoutName = null;
    var language = null;
    var clearCache = false;
    QueueIt.run(customerId, waitingRoomId, layoutName, language, clearCache, function (result) {
        console.log('QueueIt run result', JSON.stringify(result));
        if (result.Error) {
            console.warn('Errored out: ' + result.Message);
            return;
        }
        switch (result.State) {
        case 'Passed':
            // At this point the Queue-it webview is closed and the previous screen is visible
            console.log('User got his turn with token: ' + result.QueueITToken);
            break;
        case 'Disabled':
            console.log('Waiting room is disabled');
            break;
        case 'Unavailable':
            console.log('Waiting room is not available');
            break;
        case 'ViewWillOpen':
            console.log('Waiting room WebView is being opened.');
            break;
        case 'CloseClicked':
            console.log('User clicked on a `queueit://close` link, so webview was closed.');
            break;
        }
    });
}

document.querySelector('#btnEnqueue').addEventListener('click', enqueue);
