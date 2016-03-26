define [
  'backbone'
  'globalevent'
  'util'
],(
  Backbone
  GlobalEvent
  Util
) ->

  class BaseView extends Backbone.View
    onShow: ->
      GlobalEvent.on "globalevent:online", =>
        console.log "BASEVIEW ONLINE"
        Util.showPrompt Util.i18n('online_resumed')
      , @
      GlobalEvent.on "globalevent:offline", ->
        console.log "BASEVIEW OFFLINE"
        Util.showErrorPrompt Util.i18n('offline')
      , @
        
    onHide: ->
      GlobalEvent.off "globalevent:online", null, @
      GlobalEvent.off "globalevent:offline", null, @
    back: (e) ->
      console.log "going back"
      if e.stopImmediatePropagation? then e.stopImmediatePropagation()
      e.preventDefault()
      @goBack()
      false
      
    goBack: ->
      console.log "goBack called, might cause problems in TESTS"
      require ['routers'], (Router) ->
        Router.goBack()

    isPreventBack: ->
      if @preventBack? then @preventBack else false

    setPreventBack: (preventBack) ->
      @preventBack = preventBack

    pageId: ->
      
      activePage = $.mobile.pageContainer.pagecontainer("getActivePage")
      activePage[0].id

  
  # Return constructor
  BaseView
