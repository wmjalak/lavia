cordova.define("cordova/plugin/dooropener",
  function(require, exports, module) {
    var exec = require("cordova/exec");
    var DoorOpener = function() {};

    DoorOpener.prototype.open = function(lock, win, fail) {
      exec(win, fail, 'DoorOpener', 'open', [lock]);
    };

    DoorOpener.prototype.cancel = function(win, fail) {
      exec(win, fail, 'DoorOpener', 'cancel', []);
    };

    var doorOpener = new DoorOpener();
    module.exports = doorOpener;

});

if(!window.plugins) {
    window.plugins = {};
}

if (!window.plugins.doorOpener) {
    window.plugins.doorOpener = cordova.require("cordova/plugin/dooropener");
}
