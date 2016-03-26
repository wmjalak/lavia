define [
  'views/baseview'
  'util'
  'text!templates/mapsearchdialog.tmpl'
  'models/poimodel'
  'views/poiview'
], 
(
  BaseView
  Util
  mapSearchTemplate
  PoiModel
  PoiView
) ->

  class MapElement extends BaseView

    longPress: false
    
    events:
      'taphold':'onLongPress'
      'click .mapaddbuttonlayer':'onAddNewPlaceSelected'
      'click #map_placesearch li':'onSearchItemSelected'
      'click .editPlaceButton':'onEditPlaceSelected'

    initialize: (options) =>
      console.log "init"
      @mapSearchTemplate = _.template(mapSearchTemplate)
      
      @defaultLatLng = new google.maps.LatLng(60.225462, 24.863650)
      @markers = []

    onShow: ->
      super


      @clickListener = google.maps.event.addListener @map, 'click', (a) =>
        
        #@resetMarkerIcons()
        #@resetSelectedMarkerIcons()

        if @poiView? 
          @poiView.remove()

        if @longPress
          console.log "long-press click"
          @longPress = false

          poiModel = new PoiModel
            title:Util.i18n("new_place")
            lat:a.latLng.A
            lng:a.latLng.F
          @addNewPlace(poiModel)

        else
          console.log "click"
          @resetToIdle()

    onHide: ->
      super

      if @poiView? then @poiView.remove()

      if @map?
        @removeMarkers()
        google.maps.event.clearListeners @map, 'click'

      google.maps.event.removeListener(@clickListener)

      @resetToIdle()

    onEditPlaceSelected: (e) =>
      e.stopImmediatePropagation()
      e.preventDefault()
      if @poiView? 
        #@poiView.remove()
        #Util.showView new PoiView({model:model, collection:@collection}).render("edit"), undefined, (e) =>
        Util.showView @poiView.render("edit"), undefined, (e) =>
          console.log e
          console.log "done"
          #@poiView.remove()

    resetToIdle: ->
      @removeNewPlaceMarker()
      @hideAddButton()
      @hideSearchDialog()

    onLongPress: (e) =>
      e.stopImmediatePropagation()
      e.preventDefault()
      @longPress = true

    addMarkers: =>
      if @collection?
        @collection.each (model) =>
          if model.has('lat')
            @addMarker model

    addMarker: (model) ->
      marker = new google.maps.Marker
        id: model.id
        position: new google.maps.LatLng(model.get('lat'), model.get('lng'))
        map: @map
        title: model.get('title')
        #icon: "img/place.png"
        icon: @getIcon(model, false)
        #animation: google.maps.Animation.DROP
      google.maps.event.addListener marker, 'click', (a) =>
        @selectMarker marker.id, false
      @markers.push marker

    addNewPlace: (model) ->
      @removeNewPlaceMarker()

      @newPlaceMarker = new google.maps.Marker
        position: new google.maps.LatLng(model.get('lat'), model.get('lng'))
        map: @map

      @map.panTo(@newPlaceMarker.getPosition())
      @showInfo model

    removeNewPlaceMarker: ->
      if @newPlaceMarker?
        @newPlaceMarker.setMap(null)
        @newPlaceMarker = null

    removeMarkers: =>
      _.each @markers, (marker)->
        marker.setMap(null)
        google.maps.event.clearListeners marker, 'click'
      @markers = []

    
    selectMarker: (id, center = true) ->
      console.log "selectMarker " + id
      @resetToIdle()

      model = @collection.get(id)
      if center
        marker = _.findWhere(@markers, {id:id})
        if marker?
          @map.panTo(marker.getPosition())
      @showInfo model


      # handle previous selected marker
      ###
      if @selectedMarker?
        previousId = @selectedMarker.id
        selectedMarker = _.findWhere(@markers, {id:previousId})
        previousModel = @collection.get(previousId)
        if selectedMarker? and previousModel? 
          selectedMarker.setIcon(@getIcon(previousModel, false))

      model = @collection.get(id)

      @resetToIdle()
      if @selectedMarker?
        #@selectedMarker.setIcon("img/place.png")
        @selectedMarker.setIcon(@getIcon(model, false))
      @selectedMarker = _.findWhere(@markers, {id:id})
      if @selectedMarker?
        #@selectedMarker.setIcon("img/place_selected.png")
        @selectedMarker.setIcon(@getIcon(model, true))
        if center
          @map.panTo(@selectedMarker.getPosition())
        @showInfo model
      ###

    #getMarker: (id) ->


    resetSelectedMarkerIcons: ->
      if @selectedMarker?
        model = @collection.get(@selectedMarker.id)
        if model?
          @selectedMarker.setIcon(@getIcon(model, false))

    resetMarkerIcons: ->
      @removeMarkers()
      @addMarkers()
#      _.each @markers, (marker)->
#        marker.setIcon("img/place.png")


    getIcon:(model, selected) ->
      switch model.get('type')
        when "PLACE"
#          if selected
#            "img/place24_selected.png"
#          else
          "https://maps.gstatic.com/mapfiles/ms2/micons/blue.png"
#            "img/place24.png"
        when "ACCOMODATION"
#          "img/house24b.png"
          "https://maps.gstatic.com/mapfiles/ms2/micons/lodging.png"
        when "FOOD"
#          "img/food24.png"
          "https://maps.gstatic.com/mapfiles/ms2/micons/restaurant.png"
        else
          "img/cancel.png"

    
    render: ->
      console.log "render"
      @removeMarkers()

      if @collection? and @collection.length > 0
        model = @collection.at(0)
        @defaultLatLng = new google.maps.LatLng(model.get('lat'), model.get('lng'))

      if _.isUndefined @map

        myOptions = 
          zoom: 10
          center: @defaultLatLng
          panControl: false
          scaleControl: true
          overviewMapControl: true
          mapTypeId: google.maps.MapTypeId.ROADMAP
          mapTypeControl: true
          mapTypeControlOptions:
            style: google.maps.MapTypeControlStyle.DROPDOWN_MENU

        @map = new google.maps.Map(@el, myOptions)
        

      else
        google.maps.event.trigger(@map, 'resize')
      
      @map.setCenter(@defaultLatLng)
      @map.setZoom(10)
      #console.log @map.controls

      @addMarkers()

    showInfo: (model) ->
      #@poiElement.model = model
      #@poiElement.showInfo()
      
      if @poiView?
        @poiView.remove()
      
      @poiView = new PoiView({model:model, collection:@collection})

      $(@el).append @poiView.render().el


      
#      Util.showView new PoiView({model:model, collection:@collection}).render(), undefined, (e, selectedElement) =>
#        console.log "jdksj"


    showAddButton: () ->
      @hideAddButton()
      buttonLayer = "<div class='mapaddbuttonlayer'>"
      buttonLayer += "<a href='#' class='ui-btn'>Add new place</a>"
      buttonLayer += "</div>"
      infoDiv = $(buttonLayer).enhanceWithin()      
      @$el.append infoDiv

    hideAddButton: () ->
      buttonLayer = @$el.find(".mapaddbuttonlayer")
      if buttonLayer? 
        buttonLayer.hide()
        buttonLayer.remove()

    onAddNewPlaceSelected: (e) ->
      console.log "addNew"
      e.stopImmediatePropagation()
      e.preventDefault()
      lat = @newPlaceMarker.position.A
      lng = @newPlaceMarker.position.F

      poiModel = new PoiModel
        lat:"#{lat}"
        lng:"#{lng}"
      @showInfo(poiModel)

      @resetToIdle()

    showSearchDialog: () ->
      @hideSearchDialog()
      searchDiv = $("<div class='map_searchlayer'></div>")
      searchDiv.html @mapSearchTemplate
        'Util': Util
      searchDiv.enhanceWithin()
      @$el.append searchDiv
      
      $("#map-placesearch-input" ).on "input", ( e, data ) =>
        
        $ul = $("#map_placesearch" )
        console.log $ul
        $input = $(e.currentTarget)
        value = $input.val()
        html = ""
        $ul.html( "" )

        if ( value and value.length > 2 )
          $ul.html( "<li><div class='ui-loader'><span class='ui-icon ui-icon-loading'></span></div></li>" )
          $ul.listview( "refresh" )

          $.ajax
            url: "http://api.opencagedata.com/geocode/v1/json?q=#{$input.val()}&key=4ea5185a61f2189a1859d895e83cc3e3"
            dataType: "jsonp"
            crossDomain: true
            #data:
            #  q: $input.val()
          .then ( response ) =>
            @searchResponse = response

            $.each response.results, ( index, result ) =>

              html += "<li id='#{index}'>" + result.formatted + "</li>"
        
            $ul.html( html )
            $ul.listview( "refresh" )
            $ul.trigger( "updatelayout")
        


    hideSearchDialog: () ->
      $("#map-placesearch-input" )?.off()
      searchLayer = @$el.find(".map_searchlayer")
      if searchLayer? 
        searchLayer.hide()
        searchLayer.remove()
      return searchLayer != null

    onSearchItemSelected: (e) ->
      e.stopImmediatePropagation()
      e.preventDefault()
      console.log "onSearchItemSelected"
      item = @searchResponse.results[e.currentTarget.id]
      @hideSearchDialog()

      console.log item

      poiModel = new PoiModel
        title:item.formatted
        lat:item.geometry.lat
        lng:item.geometry.lng

      @resetToIdle() # remove all dialogs
      
      @addNewPlace(poiModel)



  MapElement
