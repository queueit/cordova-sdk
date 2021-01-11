const PLUGIN_NAME = 'QueueItEngine'
const exec = require('cordova/exec');

function QueueItEngine() {}

QueueItEngine.prototype.enableTesting = function (value) {
    exec(function () {
        }, function () {
        },
        PLUGIN_NAME,
        'enableTesting',
        [value]);
}

QueueItEngine.prototype.run = function (customerId, eventOrAliasId, layoutName, language, clearCache, successCallback) {
    exec(successCallback, function () {
        console.log('Error while running queue-it engine', JSON.stringify(arguments))
    }, PLUGIN_NAME, 'runAsync', [
        customerId,
        eventOrAliasId,
        layoutName,
        language,
        clearCache
    ]);
};

module.exports = QueueItEngine;
