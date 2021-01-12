const PLUGIN_NAME = 'QueueIt';
const exec = require('cordova/exec');

function QueueIt () {
}

QueueIt.enableTesting = function (value) {
    var nop = function () {};
    exec(nop, nop, PLUGIN_NAME, 'enableTesting', [value]);
};

QueueIt.run = function (customerId, eventOrAliasId, layoutName, language, clearCache, successCallback) {
    exec(successCallback, function () {
        console.log('Error while running queue-it engine', JSON.stringify(arguments));
    }, PLUGIN_NAME, 'runAsync', [
        customerId,
        eventOrAliasId,
        layoutName,
        language,
        clearCache
    ]);
};

module.exports = QueueIt;
