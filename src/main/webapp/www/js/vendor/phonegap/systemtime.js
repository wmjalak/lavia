cordova.define("cordova/plugin/systemtime",
  function(require, exports, module) {
    var exec = require("cordova/exec");
    var SystemTime = function() {};
    var timeChanged = false;

  
    SystemTime.prototype.getNanoTime = function(win, fail) {
      exec(win, fail, 'SystemTime', 'getNanoTime', []);
    };

    var systemtime = new SystemTime();
    module.exports = systemtime;

});

if(!window.plugins) {
    window.plugins = {};
}

if (!window.plugins.systemtime) {
    window.plugins.systemtime = cordova.require("cordova/plugin/systemtime");
}
