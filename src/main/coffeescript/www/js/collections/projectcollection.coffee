define [
  'backbone'
  'models/projectmodel'
  'db_util'
], (
  Backbone
  ProjectModel
  dbUtil
)->

  class ProjectCollection extends Backbone.Collection
    model: ProjectModel
    
    url: ""

    initialize: ->
      console.log "initialize PROJECTCOLLECTION"

      #@db = new PouchDB "#{dbUtil.COUCHDB_URI}/pois", { skipSetup: true }
      @db = new PouchDB "projects"


      @on "add", (model) =>
        console.log "add"
        dbUtil.add @db, model

      @on "remove", (model) =>
        console.log "remove"
        dbUtil.remove @db, model

      @on "change", (model) =>
        console.log "change"
        dbUtil.add @db, model

      console.log "initialized"



    setSync: (activate) =>

      console.log "setSync " + activate
      if not _.isUndefined(@backendSync)
        @backendSync.cancel()
      if activate is true
        @backendSync = PouchDB.sync @db, "#{dbUtil.COUCHDB_URI}/projects", 
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
#        _.each results, (result) ->
#          result.id = result._id
        if options.success?
          console.log "FETCH success"
          options.success()
        console.log results
        @reset results
        

  #_.pluck(result.rows, 'doc');
      #@db.get('pois').then (doc) ->
      #  console.log(doc)

      
    parse: (results) ->
      console.log results
      results.items

  ProjectCollection
