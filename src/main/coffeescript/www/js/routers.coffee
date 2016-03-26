define [
  'jquery'
  'backbone'
  'views/baseview'
  'views/loginview'
  'views/mapview'
  'views/dayplanview'
  'collections/poicollection'
  'collections/projectcollection'
  'models/loginmodel'
  'models/projectmodel'
  'util'
  'db_util'
  ], 
(
  $, 
  Backbone
  BaseView
  LoginView
  MapView
  DayPlanView
  PoiCollection
  ProjectCollection
  LoginModel
  ProjectModel
  Util
  DB
) ->

  class HomeController extends Backbone.Router
    routes:
      ""                                    : "showLoginPage"
      "map"                                 : "showMapPage"
      "dayplan"                             : "showDayPlan"
      "back"                                : "onBackLink"

    initialize: ->
      console.log "Router initialize"

      # global views
      @currentView = null
      @poiCollection = new PoiCollection()
      #@projectCollection = new ProjectCollection()
      @projectModel = new ProjectModel
        name:"Saksa - Italia"
        startdate:"2015-06-18"
        enddate:"2015-06-30"

    showLoginPage: =>
      console.log "show login page"
      if @poiCollection? then @poiCollection.setSync false

      DB.logout (ok) =>
        console.log "logging out (#{ok})"
        if ok
          if @poiCollection? then @poiCollection.reset()

      if not @loginView?
        @loginModel = new LoginModel()

        @loginView = new LoginView
          model:@loginModel
          #projectCollection:@projectCollection

      @changePage "#loginpage", @loginView, "", false, false, true

    showMapPage: =>
      @isLogged (logged)=>
        
        Util.showPageLoading true
        
        if @poiCollection? then @poiCollection.setSync true

        console.log "ISLOGGED: " + logged
        if logged
          if not @mapView?

            #if @projectCollection.length is 0
            #  @projectCollection.fetch()

            @mapView = new MapView
              collection:@poiCollection
              projectModel:@projectModel

          if @poiCollection.length is 0
            @poiCollection.fetch
              reset:true
              success: =>
                @changePage "#mappage", @mapView, "", false, false, true
          else
            @changePage "#mappage", @mapView, "", false, false, true

    showDayPlan: =>
      if not @dayPlanView?
        @dayPlanView = new DayPlanView
          collection:@poiCollection
          projectModel:@projectModel

      
      if @poiCollection? then @poiCollection.setSync true

      if @poiCollection.length is 0
        @poiCollection.fetch
          reset:true
          success: =>
            @changePage "#dayplanpage", @dayPlanView, "", false, false, true
      else
        @changePage "#dayplanpage", @dayPlanView, "", false, false, true

    goBack: ->
      console.log "goBack called!"
      if not @currentView?.isPreventBack() 
      	window.history.back()
      else 
        console.log "GoBack prevented"

    onBackLink: -> #Workaround for data-rel="back" not workign in Chrome. When href="#back", we go back to previous page
      console.log "onBack called!"
      window.history.go(-2) # Go back 2, since #back triggers a page change from current page.

    isLogged: (callback) ->

#      @pouchDB.getSession (err, response) =>
#        callback _.isNull(err)
      callback true

    changePage: (page, view, effect, direction, updateHash, render) ->
      if @currentView? and @currentView instanceof BaseView
        @currentView.onHide()

      if not @pageContainer?
        @pageContainer = $( ":mobile-pagecontainer" )

        @pageContainer.on "pagecontainerchange", ( event, ui ) =>
          console.log "chaneg event"
          if @currentView? and @currentView instanceof BaseView
            @currentView.onShow()

      if view? and render
        view.render()
      @currentView = view


      $(':mobile-pagecontainer').pagecontainer(
        'change'
        page
        {
            changeHash: updateHash
            transition: effect
            reverse: direction
        }
      )


  rtr = new HomeController()
  rtr
