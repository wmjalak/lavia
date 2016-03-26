# General helper class
define [
  'moment'
  ],
(
  moment
) ->

  DB =
    
    db: null
    COUCHDB_URI: "http://93.188.166.116:5984"

    initialize: ->
      console.log "DB initialize"
      #db = new PouchDB('http://93.188.166.116/couch/', { skipSetup: true })
      #@pouchDB = null
      

    initDB: =>
      console.log @db
      if _.isUndefined(@db)
        @db = new PouchDB "#{@COUCHDB_URI}/_session", { skipSetup: true }

    signup: (username, password, callback) ->
      @db.signup username, password,
        metadata:
          username:username
      , (err, response) =>
        console.log err
        callback _.isNull(err)
        
    signin: (username, password, callback) ->
      ajaxOpts =
        skipSetup: true
        ajax:
          headers: 
            Authorization: 'Basic ' + window.btoa(username + ':' + password)
      
      @db = new PouchDB "#{@COUCHDB_URI}/_session", { skipSetup: true }
      @db.login username, password, ajaxOpts,  (err, response) =>
        console.log err
        callback _.isNull(err)
          
    isLogged: (callback) ->
      #@db.getSession (err, response) =>
      #  callback _.isNull(err)
      callback true

    logout: (callback) ->
      if @db?
        @db.logout (err, response) =>
          callback _.isNull(err) 


    add: (pouchDb, model) ->
      pouchDb.post(model.attributes)
      .then (response) ->
        console.log "add/change success"
        console.log response
      .catch (err) ->
        console.log(err)
    
    remove: (pouchDb, model) ->
      pouchDb.get(model.get("_id"))
      .then (doc) =>
        pouchDb.remove(doc)
      .then (result) ->
        console.log "remove success"
        console.log result
      .catch (err) ->
        console.log(err)


  DB.initialize()
  DB
