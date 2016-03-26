define [
  'views/baseview'
  'util'
  'views/map'
  'views/projectlist'
  'text!templates/optionpanel.tmpl'
  'db_util'
  'models/poimodel'
  'text!templates/footer_navigation.tmpl'
  ], 
(
  BaseView
  Util
  MapElement
  ListElement
  panelTemplate
  DB
  PoiModel
  footerTemplate
) ->

  class MapView extends BaseView
    el: $('#mappage_content')
    panelTemplate: _.template(panelTemplate)
    footerTemplate: _.template(footerTemplate)

    events:
      'click .maplistitem':'onMaplistItemSelected'

    initialize: (options) =>

      @collection.on "add change remove reset", (model, e) => 
        console.log "collection changed"
        
        @renderList()
        if @mapElement?
          @mapElement.removeMarkers()
          @mapElement.addMarkers()

      @projectModel = options.projectModel
      
    onShow: ->
      super
      $("#mappage_headertitle").text Util.i18n("app_name")
      $(window).on 'resize', =>
        @resetContainerHeights()

      @renderList()
      @renderMap()
      if @mapElement? then @mapElement.onShow()

      $("#mappage_options").on 'click', (e) =>
        e.stopImmediatePropagation()
        e.preventDefault()
        $panel = $("#mappage_options_panel")
        $panel.html @panelTemplate
          'Util': Util
        $panel.enhanceWithin()
        $panel.panel( "open" , {} )

      $("#mappage_search").on 'click', (e) => @onSearchSelected(e)

    onHide: ->
      super
      $(window).off 'resize'
      if @mapElement? then @mapElement.onHide()

      $("#mappage_options").off()
      $("#mappage_search").off()

    render: ->
      if _.isUndefined @footerHeight
        @footerHeight = $(".ui-header").outerHeight()
      @resetContainerHeights() # set container sizes
        
      @

    renderList: =>
      if _.isUndefined @listElement
        @listElement = new ListElement
          el:@$el.find("#list-container")
          collection:@collection
          projectModel:@projectModel
      @listElement.render()

    renderMap: ->
      console.log "renderMap"
      if _.isUndefined @mapElement
        @mapElement = new MapElement
          el:@$el.find("#map-container")
          collection:@collection
      @mapElement.render()

    resetContainerHeights: ->
      console.log "resetContainerHeights"
      @setContainerHeight @$el.find("#list-container")
      @setContainerHeight @$el.find("#map-container")

    setContainerHeight: ($container) ->
      screenHeight = $.mobile.getScreenHeight()
      $container.height (screenHeight - ( (@footerHeight*2)+5 ))

    onMaplistItemSelected: (e) ->
      e.stopImmediatePropagation()
      e.preventDefault()
      
      if @mapElement?
        @mapElement.selectMarker e.currentTarget.id

    onSearchSelected: (e) ->
      e.stopImmediatePropagation()
      e.preventDefault()
      console.log "onSearchSelected"
      if @mapElement?
        @mapElement.showSearchDialog()


  MapView
