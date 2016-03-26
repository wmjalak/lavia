define [
  'views/baseview'
  'util'
  'text!templates/projectlist.tmpl'
  'text!templates/projectlistitem.tmpl'
  'moment'
  ], 
(
  BaseView
  Util
  listTemplate
  listItemTemplate
  moment
) ->

  class ListElement extends BaseView
    listTemplate: _.template(listTemplate)
    listItemTemplate: _.template(listItemTemplate)

    initialize: (options) =>
      @projectModel = options.projectModel
      #console.log @projects

    onShow: ->
      super

    onHide: ->
      super

    getDateStr: (momentObj) ->
      "#{momentObj.year()}#{momentObj.month()}#{momentObj.date()}"

    render: =>
      console.log "listelement render"
      
      @$el.html @listTemplate 
        'Util': Util
        projectModel:@projectModel

      $listElement = @$el.find("ul")
      
      dateDividerValue = @getDateStr(moment("1970-01-01"))

      unvalidModels = []

      _.each @collection.models, (model) =>
        startdate = moment(model.get("startdate"))

        if startdate.isValid()
          if dateDividerValue isnt @getDateStr(startdate)
            dateDividerValue = @getDateStr(startdate)
            $listElement.append "<li data-role=\"list-divider\">#{startdate.format("dd L")}</li>"

          $listElement.append @listItemTemplate 
            model:model
        
        else
          unvalidModels.push model

      if unvalidModels.length > 0
        $listElement.append "<li data-role=\"list-divider\">#{Util.i18n('without_time')}</li>"
      _.each unvalidModels, (model) =>
        $listElement.append @listItemTemplate 
          model:model



      ###
      project = @projects.models[0]
      startdate = moment(project.get("startdate"))
      enddate = moment(project.get("enddate"))     
      while startdate.isBefore(enddate) or startdate.isSame(enddate)
        
        startDateStr = @getDateStr(startdate)

        itemsOfDay = _.filter @collection.models, (model) =>
          st = moment(model.get("startdate"))
          startDateStr is @getDateStr(st) # "#{st.year()}#{st.month()}#{st.date()}"

        if itemsOfDay.length > 0
          $listElement.append "<li data-role=\"list-divider\">#{startdate.format("dd L")}</li>"

          _.each itemsOfDay, (model) =>
            $listElement.append @listItemTemplate 
              model:model

        startdate.add(1,'days')
      ###

      if $.mobile?
        @$el.enhanceWithin()


  ListElement
