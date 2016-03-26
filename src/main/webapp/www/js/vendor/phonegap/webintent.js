cordova.define("cordova/plugin/webintent",
  function(require, exports, module) {
    var exec = require("cordova/exec");
    var WebIntent = function() {};

    WebIntent.prototype.startActivity = function(params, win, fail) {
      exec(win, fail, 'WebIntent', 'startActivity', [params]);
    };

    var webIntent = new WebIntent();
    module.exports = webIntent;

});

if(!window.plugins) {
    window.plugins = {};
}

if (!window.plugins.webIntent) {
    window.plugins.webIntent = cordova.require("cordova/plugin/webintent");
}
