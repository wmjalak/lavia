cordova.define("cordova/plugin/powermanager",
  function(require, exports, module) {
    var exec = require("cordova/exec");
    var PowerManager = function() {};

    PowerManager.prototype.start = function(win, fail) {
      exec(win, fail, 'PowerManager', 'start', []);
    };

    PowerManager.prototype.stop = function(win, fail) {
      exec(win, fail, 'PowerManager', 'stop', []);
    };

    PowerManager.prototype.wakeup = function(triggerMillis, win, fail) {
      exec(win, fail, 'PowerManager', 'wakeup', [triggerMillis]);
    };

    PowerManager.prototype.repeatWakeup = function(intervalMillis, win, fail) {
      exec(win, fail, 'PowerManager', 'repeatWakeup', [intervalMillis]);
    };

    PowerManager.prototype.setWakeupPeriod = function(timeInSeconds, win, fail) {
      exec(win, fail, 'PowerManager', 'setWakeupPeriod', [timeInSeconds]);
    };

    var powerManager = new PowerManager();
    module.exports = powerManager;

});

if(!window.plugins) {
    window.plugins = {};
}

if (!window.plugins.powerManager) {
    window.plugins.powerManager = cordova.require("cordova/plugin/powermanager");
}
