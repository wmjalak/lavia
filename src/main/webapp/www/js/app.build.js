 ({
    appDir: "../",
    baseUrl: "js",
    dir: "../../../optimized/www",
    removeCombined: true,
    keepBuildDir: true,
    paths: {
      jquery: "vendor/jquery-2.1.1.min",
      jqueryext: "vendor/jquery.ext",
      jquerymobile: "vendor/jquery.mobile-1.4.5.min",
      underscore: "vendor/underscore-min",
      underscoreext: "vendor/underscore.ext",
      backbone: "vendor/backbone-min",
      text: "vendor/text",
      lawnchair: "vendor/lawnchair-0.6.1.min",
      cordova: "vendor/phonegap/cordova-2.4.0",
      cordovaios: "vendor/phonegap/cordova",
      nfc: "vendor/phonegap/phonegap-nfc-0.4.1",
      aes: "vendor/aes",
      notification: "vendor/jquery.notification",
      downloader: 'vendor/phonegap/downloader',
      webintent: 'vendor/phonegap/webintent',
      telephonenumber: 'vendor/phonegap/telephonenumber',
      barcodescanner: 'vendor/phonegap/barcodescanner',
      barcodescannerios: 'vendor/phonegap/barcodescannerios',
      dooropener: 'vendor/phonegap/dooropener',
      powermanager: 'vendor/phonegap/powermanager',
      systemtime: 'vendor/phonegap/systemtime',
      moment: 'vendor/moment-with-locales.min',
      momenttimezone: 'vendor/moment-timezone-with-data.min',
      datewithtimezone: 'vendor/datewithtimezone',
      pouchdb: 'vendor/pouchdb.min',
      pouchdbauthentication: 'pouchdb.authentication'

    },
    // This ensures that optimizer works with PhoneGap
    // https://github.com/jrburke/r.js/issues/170#issuecomment-5854459
    onBuildRead: function (moduleName, path, contents) {
      if (path.indexOf('cordova') === -1) {
        return contents;
      } else {
          return contents.replace(/define\s*\(/g, 'CORDOVADEFINE(');
      }
    },
    onBuildWrite: function (moduleName, path, contents) {
      if (path.indexOf('cordova') === -1) {
        return contents;
      } else {
          return contents.replace(/CORDOVADEFINE\(/g, 'define(');
      }
    },
    shim: {
      underscore: {
        exports: "_"
      },
      underscoreext: {
        deps: ["underscore"],
        exports: "_"
      },
      backbone: {
        deps: ["underscore", "jquery"],
        exports: "Backbone"
      },
      lawnchair: {
        exports: 'Lawnchair'
      },
      jquery: {
        exports: '$'
      },
      jqueryext: {
        deps : ["jquery"]
      },
      jquerymobile: {
        deps: ["jquery"]
      },
      aes: {
        exports: 'CryptoJS'
      },
      momenttimezone: {
        exports: 'moment'
      },
      cordova: {
        exports: 'cordova'
      },
      
      cordovaios: {
        exports: 'cordovaios'
      },
      
      nfc: {
        deps: ['cordova'],
        exports: 'nfc'
      },
      downloader: {
        exports: 'window.plugins.downLoader',
        deps: ['cordova']
      }, 
      barcodescanner: {
        exports: 'window.plugins.barcodeScanner',
        deps: ['cordova']
      },
      
      barcodescannerios: {
        exports: 'cordova.plugins.barcodeScanner',
        deps: ['cordovaios']
      },
      
      dooropener: {
        exports: 'window.plugins.doorOpener',
        deps: ['cordova']
      },
      powermanager: {
        exports: 'window.plugins.powerManager',
        deps: ['cordova']
      },
      systemtime: {
        exports: 'window.plugins.systemtime',
        deps: ['cordova']
      },
      telephonenumber: {
        exports: 'window.plugins.telephoneNumber',
        deps: ['cordova']
      },
      webintent: {
        exports: 'window.plugins.webIntent',
        deps: ['cordova']
      }
    },
    modules: [
      {
        name: "application"
      }
    ]
})
