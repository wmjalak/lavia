define ['backbone', 'aes', 'lawnchair'], (Backbone, CryptoJS, Lawnchair) ->
  # Generate four random hex digits
  S4 = ->
    (((1 + Math.random()) * 0x10000) | 0).toString(16).substring 1

  # Generate a pseudo-GUID by concatenating random hexadecimal
  guid = ->
    S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4()
  _ = @_

  Backbone = @Backbone

  # Our Store is represented by a single JS object in *localStorage*.
  # window.Store is deprectated, use Backbone.LocalStorage instead
  Backbone.LocalStorage = window.Store = (name, key) ->
    if name?
      @name = name
      key = key || ""
      @key = key
      store = @localStorage().getItem(@name)
      @records = (store and store.split(",")) or []
      store

  _.extend Backbone.LocalStorage::,

    clear: ->
      _.each @records, (id) =>
        @localStorage().removeItem @name + "-" + id
      @records = []
      @localStorage().removeItem @name

    isEmpty: ->
      @size() is 0

    size: ->
      storage = @localStorage().getItem(@name)
      if storage? then ((storage and storage.split(",")) or []).length
      else 0

    getName: ->
      @name

    # add item to store
    add: (obj, id) ->
      id = id || guid()
      @localStorage().setItem @name + "-" + id, CryptoJS.AES.encrypt(JSON.stringify(obj), @key)
      @records.push id
      @localStorage().setItem @name, @records.join(",")
      id

    # Retrieve item from store. Returns "undefined" if item was not found
    get: (id) ->
      item = @localStorage().getItem(@name + "-" + id)
      if item?
        try
          encrypted = CryptoJS.AES.decrypt(item, @key)
          JSON.parse encrypted.toString(CryptoJS.enc.Utf8)
        catch e
          msg = "Can't decrypt: INVALID: Crypto.AES.decrypt: " + e.message
          console.log msg
          item = undefined

    save: (obj, id) ->
      @remove id
      @add obj, id

    getFirst: ->
      recordId = @getFirstRecordId()
      if recordId? then @get recordId
      else null

    # Return the first item id of all items currently in storage
    getFirstRecordId: ->
      if not _.isEmpty(@records) then _.first(@records)
      else null

    getRecords: ->
      result = []
      _.each @records, (recordId) =>
        record = @get recordId
        if record? then result.push record
      result

    getKeys: ->
      @records

    removeFirst: ->
      recordId = @getFirstRecordId()
      if recordId? then @remove recordId

    # Delete item
    remove: (id) ->
      @localStorage().removeItem @name + "-" + id
      @records = _.reject(@records, (record_id) ->
        record_id is id
      )
      @localStorage().setItem @name, @records.join(",")
      @localStorage().removeItem @name if @records.length is 0 # if no records, remove all

    localStorage: ->
      localStorage

  Storage =
    store: (bucketName, entity, successCb) ->
      Lawnchair {adapter: 'dom', name: bucketName}, (store) ->
        store.save entity,
        (saved) =>
          if successCb? then successCb(saved)

    get: (bucketName) ->
      items = []
      Lawnchair {adapter: 'dom', name: bucketName}, (store) ->
        store.keys (keys) =>
          _.each keys, (key) =>
            store.get key, (obj) =>
              items.push obj
      items

    remove: (bucketName, key) ->
      Lawnchair {adapter: 'dom', name: bucketName}, (store) ->
        store.remove key

  Storage