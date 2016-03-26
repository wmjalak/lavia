define [
  'views/baseview'
  'util'
  'text!templates/poielement.tmpl'
  'moment'
  ], 
(
  BaseView
  Util
  poiElementTemplate
  moment
) ->

  class PoiElement extends BaseView
    poiElementTemplate: _.template(poiElementTemplate)

    events:
      'click .editPlaceButton':'onEditPlaceSelected'
      'click .mapinfolayer .selectionlayer':'onMapInfoLayerSelected'
      'click #poi_saveBtn':'onSavePlaceSelected'
      'click #poi_deleteBtn':'onDeletePlaceSelected'

    remove: ->
      @getLayer()?.off().remove()

    hide: (callback) ->
      layer = @getLayer()
      if layer?
        layer.hide 'slow', => 
          @remove()
          if callback? then callback()
      else if callback? then callback()

    getLayer: ->
      infoLayer = $(@el).find(".mapinfolayer")
      if infoLayer.length > 0 then infoLayer else null

    showInfo: ->
      type = "small"
      #if not @model.id? then type = "edit"
      @remove()

      @render(type)

    onMapInfoLayerSelected: (e) ->
      e.stopImmediatePropagation()
      e.preventDefault()

      $moreinfo = $(@el).find(".mapinfolayer .moreinfo")
      if $moreinfo.length > 0
        $moreinfo.toggle("slow")

    onEditPlaceSelected: (e) =>
      e.stopImmediatePropagation()
      e.preventDefault()
      @render("edit")

    onSavePlaceSelected: (e) =>
      e.stopImmediatePropagation()
      e.preventDefault()

      infoLayer = @getLayer()
      if infoLayer?
        #visitday = moment(infoLayer.find("#visitday").val(), "DD.MM.YYYY")
        format = moment.localeData().longDateFormat("L")
        start_date = moment(infoLayer.find("#startdate").val(), format)
        end_date = moment(infoLayer.find("#enddate").val(), format)
        
        start_time = infoLayer.find("#starttime").val()
        start_date.hours(start_time)
        start_date.minutes(0)

        end_time = infoLayer.find("#endtime").val()
        end_date.hours(end_time)
        end_date.minutes(0)

        @model.set
          title:infoLayer.find("#name").val()
          streetAddress:infoLayer.find("#address").val()
          lat:infoLayer.find("#lat").val()
          lng:infoLayer.find("#lng").val()
          description:infoLayer.find("#description").val()
          startdate:start_date.format()
          enddate:end_date.format()
          type:infoLayer.find("#type").val()
          created:Util.getServerFormattedDate()

        @collection.add @model, {merge:true}
        @hide()

    onDeletePlaceSelected: (e) ->
      e.stopImmediatePropagation()
      e.preventDefault()

      infoLayer = @getLayer()
      if infoLayer?
        id = infoLayer.find("#id").val()
        model = @collection.get(id)
        if model?
          @collection.remove model
          @hide()
    
    setupDatepicker: ->

      capitalize = (stringArray) ->
        _.map stringArray, (string) ->
          string.charAt(0).toUpperCase() + string.substring(1).toLowerCase()

      require ['datepicker'], =>
        format = moment.localeData().longDateFormat("L").toLowerCase()
        format = format.replace("yyyy","yy")

        $(@el).find(".date-input-css").datepicker
          dateFormat:format
          monthNames:capitalize(moment.months())
          dayNamesMin:capitalize(moment.weekdaysShort())
          firstDay:moment().startOf("week").day()

    getHoursArray: ->
      hours = []
      num = 0
      d = moment()
      d.hours(0)
      d.minutes(0)
      while num < 24
        hours.push d.format("LT")
        d.add(1, 'hours')
        num++
      hours

    render: (viewType = "small") =>
      console.log "poielement render"

      @setupDatepicker()

      console.log @model
      hours = @getHoursArray()

      infoLayer = $('<div class="mapinfolayer"></div>')
      infoLayer.html @poiElementTemplate
        'Util': Util
        model:@model
        show:viewType
        hours:hours

      switch viewType
        when "small"
          infoLayer.find(".moreinfo").hide()
        when "edit"
          infoLayer.hide()

      infoLayer.enhanceWithin()
      $(@el).append infoLayer

      switch viewType
        when "edit"
          infoLayer.slideUp "slow", =>
            infoLayer.slideDown("slow")
          #infoLayer.slideUp "slow", =>

      @

    renderElement: (viewType = "small") =>
      console.log "poielement render"

      @setupDatepicker()

      hours = @getHoursArray()

      infoLayer = $('<div class="mapinfolayer"></div>')
      infoLayer.html @poiElementTemplate
        'Util': Util
        model:@model
        show:"edit"
        hours:hours

      #switch viewType
      #  when "small"
      #    infoLayer.find(".moreinfo").hide()
      #  when "edit"
      #    infoLayer.hide()

      #infoLayer.enhanceWithin()
      #$(@el).prepend infoLayer

      #switch viewType
      #  when "edit"
      #    infoLayer.slideUp "slow", =>
      #      infoLayer.slideDown("slow")
          #infoLayer.slideUp "slow", =>

      infoLayer.html()

  PoiElement
