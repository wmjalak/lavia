require.config
  #deps : ["main"]
  paths: 
    jquery : "vendor/jquery-2.1.1.min"
    jqueryext: "vendor/jquery.ext"
    jquerymobile : "vendor/jquery.mobile-1.4.5.min"
    underscore : "vendor/underscore-min"
    underscoreext: "vendor/underscore.ext"
    backbone : "vendor/backbone-min"
    text: "vendor/text"
    lawnchair : "vendor/lawnchair-0.6.1.min"
    cordova: "vendor/phonegap/cordova-2.4.0"
    cordovaios: "vendor/phonegap/cordova"
    nfc: "vendor/phonegap/phonegap-nfc-0.4.1"
    aes: "vendor/aes"
    notification: "vendor/jquery.notification"
    downloader: 'vendor/phonegap/downloader'
    webintent: 'vendor/phonegap/webintent'
    telephonenumber: 'vendor/phonegap/telephonenumber'
    barcodescanner: 'vendor/phonegap/barcodescanner'
    barcodescannerios: 'vendor/phonegap/barcodescannerios'
    dooropener: 'vendor/phonegap/dooropener'
    powermanager: 'vendor/phonegap/powermanager'
    systemtime: 'vendor/phonegap/systemtime'
    moment: 'vendor/moment-with-locales.min'
    momenttimezone: 'vendor/moment-timezone-with-data.min'
    datewithtimezone: 'vendor/datewithtimezone'
    swiper : 'vendor/swiper'
    hammer: 'vendor/hammer'
    pouchdb: 'vendor/pouchdb'
    pouchdbauthentication: 'vendor/pouchdb.authentication'
    "jquery-ui/datepicker" : "vendor/datepicker"
    datepicker : "vendor/jquery.mobile.datepicker"

    #pauth: 'vendor/pouchdb.authentication'

  #waitSeconds: 5
  shim:
    underscore:
      exports: "_"
    underscoreext:
      deps : ["underscore"]
      exports: "_"
    backbone :
      deps : ["underscore","jquery"]
      exports : "Backbone"
    lawnchair:
      exports: 'Lawnchair'
    jquery: 
      exports: '$'
    jqueryext:
      deps : ["jquery"]
    jquerymobile:
      deps : ["jquery"]
    swiper:
      deps : ['jquery']
    aes:
      exports: 'CryptoJS'
    momenttimezone:
      deps: ['moment']
    cordova:
      exports:'cordova'
    cordovaios:
      exports:'cordovaios'
    nfc:
      deps: ['cordova']
      exports: 'nfc'
    downloader:
      exports:'window.plugins.downLoader'
      deps: ['cordova']
    barcodescanner:
      exports:'window.plugins.barcodeScanner'
      deps: ['cordova']    
    barcodescannerios:
      exports:'cordova.plugins.barcodeScanner'
      deps: ['cordovaios']    
    dooropener:
      exports:'window.plugins.doorOpener'
      deps: ['cordova']
    powermanager:
      exports:'window.plugins.powerManager'
      deps: ['cordova']
    systemtime:
      exports:'window.plugins.systemtime'
      deps: ['cordova']
    telephonenumber:
      exports:'window.plugins.telephoneNumber'
      deps: ['cordova']
    webintent:
      exports:'window.plugins.webIntent'
      deps: ['cordova']
#    pauth:
#      deps: ['pouchdb']
#      exports:'PouchDB'
      
#    pouchdbauthentication: ['pouchdb']

    
  config: 
    text: 
      useXhr: (url, protocol, hostname, port) -> true # allow all suffixes 

#Sets up mobile stuff
require ['jquery'], ($) ->
  console.log "Setting mobile stuff"
  $(document).bind "mobileinit", ->
    console.log "jqm-config - mobileinit"
    ###
    if navigator.userAgent.match(/(iPhone|iPod|iPad)/)
      require ['cordovaios'], -> console.log "iOS specific cordova loaded"

      # iOS workaround for buggy header/footer when virtual keyboard is on/off
      $(document).on 'focus', 'input, textarea', ->
        setTimeout ->
          window.scrollTo document.body.scrollLeft, document.body.scrollTop
        ,0
      $(document).on 'blur', 'input, textarea', ->
        setTimeout ->
          $.mobile.silentScroll($('div[data-role="header"]').offset().top)
          window.scrollTo document.body.scrollLeft, document.body.scrollTop
        ,0
    ###
    $.mobile.ajaxEnabled = false
    $.mobile.linkBindingEnabled = false
    $.mobile.hashListeningEnabled = false # disable jQM hashchange listening
    $.mobile.pushStateEnabled = false
    $.mobile.allowCrossDomainPages = true
    $.support.cors = true
    $.mobile.buttonMarkup.hoverDelay = true
    # here we can add our own variables like this:
    $.extend $.mobile,
      applicationName: "Mobilog"

  # Start the application  
  # Instantiate jquerymobile and router by requiring them
  # Start backbone history to allow navigation to start
require ['jquerymobile', 'routers' ], (jqm, Router) ->
  $ -> # wait for DOM to get fully loaded
    console.log "Backbone history start"
    Backbone.history.start()


    
    
