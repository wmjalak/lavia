define [
  'backbone'
  'models/poimodel'
  'db_util'
], (
  Backbone
  PoiModel
  dbUtil
)->

  class PoiCollection extends Backbone.Collection
    model: PoiModel
    
    url: ""
    events: []
    columnIndexes: []

    initialize: ->
      console.log "initialize POICOLLECTION"

      #@db = new PouchDB "#{dbUtil.COUCHDB_URI}/pois", { skipSetup: true }
      @db = new PouchDB "pois"


      @on "add", (model) =>
        console.log "add"
        dbUtil.add @db, model

      @on "remove", (model) =>
        console.log "remove"
        dbUtil.remove @db, model

      @on "change", (model) =>
        console.log "change"
        dbUtil.add @db, model

      @on "reset", () =>
        #@events = @getAllEvents()
        @resetAllEvents()

      console.log "initialized"


    setSync: (activate) =>
      if not _.isUndefined(@backendSync) and activate is false
        @backendSync.cancel()
        @backendSync = undefined

      if _.isUndefined(@backendSync)

        console.log "setSync " + activate
        if activate is true
          @backendSync = PouchDB.sync @db, "#{dbUtil.COUCHDB_URI}/pois", 
            live: true
            retry: true
          .on 'change', (info) =>
            @trigger("reset")
            console.log "CHANGED"
            @fetch()
          .on 'denied', (info) =>
            console.log "DENIED"

    fetch: (options) ->
      options || (options = {})
      
      @db.allDocs({include_docs:true}).then (results) =>
        results = _.pluck(results.rows, 'doc')
        if options.success?
          console.log "FETCH success"
          options.success()
        @reset results
        
      
    parse: (results) ->
      console.log results
      results.items

    comparator: (item) ->
      item.get("startdate")

    getDateTimeIndex: (momentObj) ->
      momentObj.format("YYYYMMDDHH")

    getEvents: (momentObj) =>
      @events[@getDateTimeIndex(momentObj)]

    resetAllEvents: () =>
      console.log "getAllEvents"
      @events = []

      @columnIndexes = []

      console.log @models
      _.each @models, (model, index) =>
        id = model.id
        type = model.get('type')
        mStartDate = moment(model.get("startdate"))
        mEndDate = moment(model.get("enddate"))
        
        columnIndex = undefined
        if mStartDate.isValid() and mEndDate.isValid()
          while (mStartDate.isBefore(mEndDate))

            index = @getDateTimeIndex(mStartDate)

            if _.isUndefined(@events[index])
              @events[index] = []
            if _.isUndefined(columnIndex)
              columnIndex = @events[index].length
            
            #@events[index].push {id:id,columnIndex:columnIndex}
            @events[index][columnIndex] = {id:id,type:type}

            mStartDate.add(1, 'hours')

    ###
    getItems: (date) =>
      console.log "getItems"

      items = []
      startDate = moment(date)
      startDate.hours(0)
      endDate = moment(date)
      endDate.hours(23)
      endDate.minutes(59)
      #console.log startDate.format() + " - " + endDate.format()


      pois = []

      testModels = _.filter @models, (model, index) ->
        index is 0

      _.each testModels, (model, index) =>
        id = model.get("id")
        mStartDate = moment(model.get("startdate"))
        mEndDate = moment(model.get("enddate"))
        

        if mStartDate.isValid() and mEndDate.isValid()
          while (mStartDate.isBefore(mEndDate))

            hour = Number(mStartDate.hours())

            console.log "index: "+index + ", hour: " + hour

            mStartDate.add(1, 'hours')



      console.log pois
      items
    ###

  PoiCollection
