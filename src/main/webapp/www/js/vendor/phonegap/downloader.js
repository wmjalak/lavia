cordova.define("cordova/plugin/downloader",
  function(require, exports, module) {
    var exec = require("cordova/exec");
    var Downloader = function() {};

    Downloader.prototype.downloadFile = function(fileUrl, params, win, fail) {
      exec(win, fail, 'Downloader', 'downloadFile', [fileUrl, params]);
    };

    var downLoader = new Downloader();
    module.exports = downLoader;

});

if(!window.plugins) {
    window.plugins = {};
}

if (!window.plugins.downLoader) {
    window.plugins.downLoader = cordova.require("cordova/plugin/downloader");
}
