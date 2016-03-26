# General helper class
define [
  'globalevent'
  'backbone'
  'lawnchair' 
  'i18n_fi'
  'i18n_en'
  'models/devicemodel'
  'notification'
  'moment'
  'datewithtimezone'
  ],
(
  GlobalEvent 
  Backbone
  Lawnchair 
  i18n_fi
  i18n_en
  DeviceModel
  notification 
  moment
  DateWithTimezone
  ) ->

  Util =
    current_language: 'fi' # default language to EN
    languages: 
      fi: i18n_fi
      en: i18n_en

    initialize: ->
      console.log "Util initialize"
      @itemQueue = []
      @setLanguage @current_language
      @dateWithTimezone = new DateWithTimezone()


    flash: (msg, theme, delay, callback) ->
      notification.notify msg, null, null, delay

    encodeBasicAuthValue: (username, password) ->
      "Basic ".concat btoa(username.concat(":", password))

    fail: (reason) ->
      navigator.notification.alert reason, (->
      ), "There was a problem"

    log: (obj) ->
      console.log obj

    logText: (msg) ->
      console.log "LOG (#{new Date().toISOString()}): #{msg}"

    showPageLoading: (active, msg) ->
      if not active then $.mobile.loading( 'hide' )
      else
        if msg? and msg isnt ''
          $.mobile.loading( 'show', {text:msg, textVisible: true} )
        else
          $.mobile.loading( 'show' )

    showPrompt: (msg, theme, delay, callback) ->
      delay = 3000  if typeof (delay) is "undefined" # in milliseconds
      notification.notify msg, null, null, delay

    showTagInput: (callback) ->
      listdata = []
      listdata.push "<div data-role='popup' data-theme='a' data-overlay-theme='a' class='minor-padding'>"
      listdata.push "<form><h3>" + Util.i18n('tag_input') + "</h3>"
      listdata.push "<input type='text' value='' placeholder='" + Util.i18n('tag_id') + "' />"
      listdata.push "<button class='ui-btn-d' type='submit'>" + Util.i18n('ok') + "</button>"
      listdata.push "</form></div>"
      popupElement = $(listdata.join(""))
      @addPopupQueueItem $(popupElement), (e) =>
        if e.target?
          value = e.target.form[0]?.value # form input field value
          if value? and value.length > 0 then callback value

    showErrorPrompt: (msg,theme,delay) ->
      delay = 3000  if typeof (delay) is "undefined" # in milliseconds
      notification.notifyError msg, null, null, delay

    showBadRequestErrorPrompt: (errorObject, defaultMsg, delay) ->
      if _.isString errorObject then errorObject = JSON.parse msg
      errorMessage = ""

      # parse field errors
      fieldErrors = errorObject?.errors?.fieldErrors
      if fieldErrors? and not _.isArray(fieldErrors) then fieldErrors = [fieldErrors]
      if fieldErrors?
        errorMessage += _.map(fieldErrors, (f) ->
          code = f.messageCode?.replace(/\./g,"_")
          msg = f.message
          if code? and Util.i18n(code) isnt code then msg = Util.i18n(code)
          msg
        ).join '.'

      #parse global errors
      globalErrors = errorObject?.errors?.globalErrors
      if globalErrors? and not _.isArray(globalErrors) then globalErrors = [globalErrors]
      if globalErrors?
        _.map(globalErrors, (g) ->
          code1 = g.messageCode?.replace(/\./g,"_")
          code2 = [g.objectName? + g.messageCode].join(".")?.replace(/\./g,"_")
          msg = g.message
          if not _.isEmpty(code1) and Util.i18n(code1) isnt code1 then msg = Util.i18n(code1)
          if not _.isEmpty(code2) and Util.i18n(code2) isnt code1 then msg = Util.i18n(code2)
          msg
        ).join '.'

      if _.isEmpty(errorMessage) then errorMessage = Util.i18n(defaultMsg)
      Util.showPrompt errorMessage, "y", delay

    # accept array with parameters: id, text, icon, type ("DIVIDER"|"")
    showItemList: (elementId, listItems, callback) ->
      listdata = []
      _.each listItems, (item) ->
        listdata.push "<li"
        if item.type is "DIVIDER"
          listdata.push " data-role='list-divider'>"+item.text+"</li>"
        else
          if item.icon?
            listdata.push " data-icon='"+item.icon+"'"
          listdata.push "><a href=''"
          listdata.push " id='"+item.id+"'>"+item.text+"</a></li>"
      Util.showList elementId, listdata.join(""), callback

    showList: (elementId, htmldata, callback, popupOptions) ->
      console.log "showList "
      if htmldata.length is 0 then return
      listPopup = $ elementId # create selection popup
      list = $(listPopup).find("ul:first")
      list.empty()
      list.append htmldata
      list.listview("refresh")
      result_id = ""
      result_text = ""
      list.on 'click', (e) ->
        e.stopImmediatePropagation()
        e.preventDefault()
        if $(e.target).attr('data-role')  is 'list-divider' then return
        result_id = e.target.id
        result_text = e.target.text

        switch result_id
          when "-1"
            popuplist_inputfield = $(listPopup).find("#popuplist_inputfield")
            if popuplist_inputfield? and popuplist_inputfield.length > 0 # received value from input field
              result_text = popuplist_inputfield.val()
              if popuplist_inputfield.val() is "" then result_id = ""
            else # create text input field named 'popuplist_inputfield'
              e.target.innerHTML = "<input id='popuplist_inputfield' type='text' value='' placeholder='"+e.target.text+"' />"
              listPopup.trigger('create')
              console.log 'Created input field, now trying focus'
              $(listPopup).find("#popuplist_inputfield").focus().click().trigger('click')
              result_id = ""
          when "popuplist_inputfield" # ignore text input clicks
            result_id = ""

        if result_id isnt "" then listPopup.popup("close") # close popup
        else if e.target.id is "" and e.target.href? then document.location.href = e.target.href

      listPopup.on 'popupafterclose', => # have to set timeout here: JQM Chaining of popups not allowed
        listPopup.off('popupafterclose')
        list.off('click')
        setTimeout ( =>
          if result_id isnt "" then callback result_id,result_text
          #console.log "showList timeout"
        ), 100

      if(popupOptions)
        listPopup.popup(popupOptions)

      listPopup.popup("open") # show selection popup

    showForm: (elementId, htmldata, callback) ->
      inputPopup = $ elementId # get popup handle
      inputPopup.empty()
      inputPopup.append htmldata
      inputButton = inputPopup.find("button[type=submit]")
      inputPopup.trigger('create')
      result = ""
      inputButton.on 'click', (e) =>
        e.stopImmediatePropagation()
        e.preventDefault()
        result = e
        inputPopup.popup("close") # close popup
      inputPopup.on 'popupafterclose', => # have to set timeout here: JQM Chaining of popups not allowed
        inputPopup.off('popupafterclose')
        inputButton.off('click')
        setTimeout ( =>
          if callback? then callback result
        ), 100
      inputPopup.popup("open") # show input popup

    openDialog: (elementId, textArray, callback) -> #if callback returns false, then don't close
      console.log "Showing dialog"
      d = $ elementId # get popup handle
      dialogBtn = d.find("button[type=submit]")

      _.each textArray, (value, key, list) ->
        k = d.find("#" + key)
        if k? then k.text value

      # TODO find out a better way to remove Close button
      d.trigger('create')
      d.dialog().dialog( "widget" ).find( ".ui-dialog-titlebar-close" ).hide()

      result = ""
      dialogBtn.on 'click', (e) =>
        e.stopImmediatePropagation()
        e.preventDefault()
        if callback? and callback(e) isnt false
          d.off('pagecreate')
          dialogBtn.off('click')
          d.dialog("close") # close popup
      d.on 'pagecreate', (e) =>
        console.log "CREATE"
        d.find("a[data-icon='delete']").hide()
      $.mobile.changePage d, {changeHash: false, transition: 'pop', role: 'dialog'}

    showPopup: (html, $positioningElement, callback) ->
      html = '<div data-theme="a" data-overlay-theme="a">'+html+'</div>'
      popupElement = $(html)
      if $.mobile? 
        popupElement.popup().enhanceWithin()
      
      submitButton = popupElement.find("a,button")
      result = undefined
      selectedElement = null

      if submitButton?
        submitButton.on 'click', (e) =>
          e.stopImmediatePropagation()
          e.preventDefault()          
          result = popupElement
          selectedElement = e
          if $.mobile? 
            popupElement.popup("close") # close popup
          else 
            popupElement.trigger("popupafterclose")
      

      popupElement.on 'popupafterclose', =>
        popupElement.off('popupafterclose')
        if submitButton? then submitButton.off('click')
        popupElement.remove()
        if callback?
          callback result,selectedElement
      options = {}
      if $positioningElement?
        y = $positioningElement.offset().top + (popupElement.outerHeight()/2)
        options = {y:y}
      
      if $.mobile? 
        popupElement.popup("open", options)
      popupElement

    showView: (view, $positioningElement, callback) ->

      #html = '<div data-theme="a" data-overlay-theme="a">'+html+'</div>'
      #popupElement = $(html)
      
      #view.delegateEvents()
      popupElement = $(view.el)

      if $.mobile? 
        popupElement.popup().enhanceWithin()
      
      submitButton = popupElement.find(".editPlaceButton")

      
      #popupElement.find(".editPlaceButton").on "click", ->
      #  console.log "EDIT!"

      result = undefined
      selectedElement = null
      if submitButton?
        submitButton.on 'click', (e) =>
          e.stopImmediatePropagation()
          e.preventDefault()          
          result = popupElement
          selectedElement = e
          if $.mobile? 
            popupElement.popup("close") # close popup
          else 
            popupElement.trigger("popupafterclose")
      
      popupElement.on 'popupafterclose', =>
        popupElement.off('popupafterclose')
        if submitButton? then submitButton.off('click')
        popupElement.remove()
        if callback?
          callback result,selectedElement
      options = {}
      if $positioningElement?
        y = $positioningElement.offset().top + (popupElement.outerHeight()/2)
        options = {y:y}
      
      if $.mobile? 
        popupElement.popup("open", options)
      popupElement

    createImagePopup: (imageClass) ->
      popup = '<div data-role="popup" data-theme="a" data-shadow="true" data-overlay-theme="a" data-dismissible="false" class="ui-content">'
      popup = popup + '<a href="#" data-rel="back" data-role="button" data-theme="a" data-icon="delete" data-iconpos="notext" class="ui-btn-right"></a>'
      popup = popup + "<p><span id='img' class='"+imageClass+"'></span>"
      popup = popup + "<h3 class='custom-center'>"  + @i18n('read_tag') + "</h3>"
      popup = popup + "</p></div>"
      popupElement = $(popup).popup()
      popupElement.trigger('create')
      popupElement

    createPopup: (popup, callback) ->
      popup.popup() # init popup
      popup.trigger('create')
      submitButton = popup.find("button[type=submit]")
      result = ""
      if submitButton?
        submitButton.on 'click', (e) =>
          e.stopImmediatePropagation()
          e.preventDefault()
          result = e
          popup.popup("close") # close popup
      popup.on 'popupafterclose', => # have to set timeout here: JQM Chaining of popups not allowed
        popup.off('popupafterclose')
        if submitButton? then submitButton.off('click')
        setTimeout ( =>
          if callback? then callback result
        ), 100
      popup

    openConfirmationPopup: (options, callback) ->
      tmpl = _.template($("#confirmation-dialog-template").html())
      opts = _.defaults(options || {}, { text: "", okButtonLabel: "Ok", cancelButtonLabel: "Cancel" })
      tmp = tmpl opts
      Util.addPopupQueueItem($(tmp), callback)

    openConfirmationDialog: (options, callback) ->

      if not @$confirmationDialog?
        @$confirmationDialog = $("#confirmation_dialog")
      console.log "openConfirmationDialog"
      @$confirmationDialog.find("#title").text options.title
      @$confirmationDialog.find("#text").html options.text
      @$confirmationDialog.find("ul").html items
      @$confirmationDialog.find("#yes").text options.yes
      @$confirmationDialog.find("#no").text options.no
      if not _.isEmpty(options.items)
        items = _.map(options.items, (text)->"<li>#{text}</li>").join(" ")
        @$confirmationDialog.find("ul").html items
      @$confirmationDialog.find(".confirmation_dialog_button").unbind("click").on "click", (e) =>
        e.stopImmediatePropagation()
        e.preventDefault()
        @$confirmationDialog.dialog?("close")
        callback e.currentTarget?.id is "yes"
        $(@).off("click")
      @$confirmationDialog.trigger("create").dialog?({ closeBtn: "none" })
      $.mobile?.changePage @$confirmationDialog, {changeHash: false, transition: 'pop', role: 'dialog'}
      @$confirmationDialog

    showModalNotification: (text, callback) ->
      popupElement = _.template $('#notifier-template').html(), {title:text}
      Util.addPopupQueueItem $(popupElement), callback

    addPopupQueueItem: (element, callback) ->
      popup = Util.createPopup element.clone(), (result) =>
        @queueItem = undefined
        if callback? then callback(result)
        Util.displayQueueItem()
      @itemQueue.push popup
      Util.displayQueueItem()

    displayQueueItem: ->
      if _.isUndefined(@queueItem) and (@queueItem = @itemQueue.shift())
        switch @queueItem.attr("data-role")
          when "popup"
            #prevent scrolling when popup is active
            @queueItem.one "popupafteropen", =>
              $("body").css("overflow", "hidden")
              @queueItem.one "popupafterclose", =>
                $("body").css("overflow", "")

            @queueItem.popup("open")
            GlobalEvent.trigger "globalevent:popup_open", @queueItem

    enableElement: (el, elementName, enable) ->
      element = $(el).find(elementName)
      if element?
        tagName = if element.get(0)? then element.get(0).tagName else ""
        element.toggleClass 'ui-state-disabled', not enable
#        if tagName? and tagName is "BUTTON"
          #element.button if enable then 'enable' else 'disable'
#        else
        element.toggleClass 'ui-disabled', not enable
        #if enable then element.removeClass('ui-disabled') else element.addClass('ui-disabled')
        element.prop("disabled", not enable)

#<a href="#" class="ui-btn ui-state-disabled">Disabled anchor via class</a>
#<button disabled="">Button with disabled attribute</button>

    showElement: (el, elementName, show) ->
      console.log "hide element ", elementName, show
      element = $(el).find(elementName)
      if element?
        tagName = if element.get(0)? then element.get(0).tagName else ""
        if tagName? and tagName is "BUTTON"
          element = element.closest('.ui-btn')
        if show is true
          element.show()
        else
          element.hide()

    reapplyStyles: (el) ->
      $(el).trigger("create")

    reapplyStylesForWholePage: (el) ->
      $(@el).page('destroy').page()

    getActivePage: ->
      $.mobile.activePage.attr('id')

    getMinutesAsString: (minutes) ->
      if _.isString minutes
        minutes = parseInt(minutes, 10)
      hours = Math.floor(minutes / 60)
      mins = minutes % 60
      if _.isNaN(hours) then hours = 0
      if _.isNaN(mins) then mins = 0
      ret = @addZero(hours) + ":" + @addZero(mins)
      ret

    # 2012-03-11T12:30:30+02:00
    # yyyy-MM-ddThh:mm:ss
    getAsDate: (dateStr) ->
      @dateWithTimezone.convertToDate dateStr

    getAsMoment: (dateStr) ->
      dateStr = dateStr || Util.getDate()
      @dateWithTimezone.convertToMoment dateStr

    syncTime: (callback) ->
      dateTimeModel = new Backbone.Model()
      dateTimeModel.url = "/systemTime"
      dateTimeModel.fetch success: =>
        @dateWithTimezone.detectTimezone()
        localDate = Util.getAsDate(dateTimeModel.get('dateTime').dateTime)
        Util.setBaseTimestamp(localDate.getTime(), DeviceModel.getNanoTime())
        if callback? then callback()

    setBaseTimestamp: (timestamp, nanotime) =>
      console.log "Util.setBaseTimestamp(#{timestamp},#{nanotime})"
      @baseTimestamp = timestamp
      @baseNanotime = nanotime

    # get current Date
    getDate: =>
      if @baseTimestamp? and @baseNanotime?
        console.log "Calculating date based on base time"
        m = moment(@baseTimestamp).add('milliseconds', DeviceModel.getNanoTime() - @baseNanotime)
        return m.toDate()
      else return new Date()

    formatDate: (date, format) ->
      if _.isUndefined(date) or date is "" then ""
      else moment(date).format(format)

    getText: (text) ->
      if text? then _.escape(text) else ""

    i18n: (key) ->
      if @i18n_keys[key]? then @i18n_keys[key] else ""

    setLanguage: (lang) ->
      if @getLanguages()[lang]?
        @i18n_keys = @getLanguages()[lang]
        @current_language = lang
        moment.locale lang
        console.log "Language changed: #{lang}"
        GlobalEvent.trigger "globalevent:language_changed", lang
      else
        console.log "Language #{lang} not supported or already in use"

    getLanguage: () ->
      @current_language

    getLanguages: () ->
      @languages
      
    # make sure that all languages have the same keys defined
    testI18nKeys: ->
      allKeys = []
      #Loop all keys in all languages
      _.each _.keys(@languages), (lang) =>
        @setLanguage lang
        _.each _.keys(@i18n_keys), (k) =>
          if k not in allKeys then allKeys.push k
      # Figure out which ones are missing for all languages
      missingKeys = {}
      _.each _.keys(@languages), (lang) =>
        @setLanguage lang
        missingKeys[lang] = _.difference(allKeys, _.keys(@i18n_keys))

      msg = ""
      # Return message if something is missing
      _.each _.keys(@languages), (lang) =>
        if missingKeys[lang]?.length > 0 then msg += "Keys missing from #{lang}: " + missingKeys[lang].join(",")
      msg

    getFormattedDate: (date, format) ->
      date = date || Util.getDate()
      @dateWithTimezone.convertToMoment(date).format(format)

    getServerFormattedDate: (date) ->
      Util.getFormattedDate date

    setTimezone: (timezone) ->
      @dateWithTimezone.setTimezone(timezone)

    addZero: (i, length) -> # add leading zeros
      length = length || 2 # default length
      str = String(i)
      while (str.length < length)
        str = "0" + str
      str

    parseNumbers: (value) ->
      if value? then value = value.replace(/[^0-9]/g,'')
      value

    getVersion: ->
      el = document.getElementById('mobilogVersion')
      if el? then el.getAttribute("content")
      else ''

    loadFromStorage: (storeName, key, callback) ->
      Lawnchair {adapter: 'dom',name:storeName}, (store) =>
        store.get key, (obj) =>
          result = ""
          if obj?.value? and not _.isUndefined(obj.value)
            result = obj.value
          callback result

    formatDuration: (durationInMinutes) ->
      minutes = parseInt(durationInMinutes, 10)
      if minutes <= 60
        return "#{minutes}min"
      else
        duration = moment.duration(minutes, 'minutes')
        hours = parseInt(duration.asHours(), 10)
        text = "#{hours}h"
        if duration.minutes() > 0 then text = text + " #{duration.minutes()}min"
        return text

    saveToStorage: (storeName, key, value) ->
      Lawnchair {adapter: 'dom',name:storeName}, (store) =>
        store.save {key:key,value:value}

    parseAndShowErrorPrompt: (response, defaultMessage) ->
      resp = JSON.parse(response.responseText)
      error = null
      if _.isArray resp?.globalErrors
        error = resp.globalErrors[0]
      else
        error = resp.globalErrors
      message = ""
      if error?.objectName and error?.messageCode
        message = Util.i18n("#{error.messageCode}_#{error.objectName}")
      if _.isEmpty message then message = Util.i18n(defaultMessage)
      Util.showErrorPrompt message

    showSelectList: (e, itemlist, callback) ->
      options = {}
      $target = undefined
      if e?
        $target = $(e.currentTarget)
        y = $target.offset().top + $target.height()
        options = {x:$target.offset().left,y:y}
      popupdata = []
      popupdata.push "<div id='popup' class='ui-corner-all' data-shadow='false' data-overlay-theme='a'"
      popupdata.push " data-theme='a' data-role='popup' data-position-to='origin'>"
      popupdata.push "<ul data-role='listview' data-inset='true'>"
      _.each itemlist, (item) ->
        popupdata.push "<li data-icon='false'><a href='#'>"+item+"</a></li>"
      popupdata.push "</ul>"
      popupdata.push "</div>"

      popupElement = $(popupdata.join("")).popup() # init popup

      submitButton = popupElement.find("li a")
      result = ""
      if submitButton?
        submitButton.on 'click', (e) =>
          e.stopImmediatePropagation()
          e.preventDefault()
          #console.log e
          result = e.currentTarget.text
          popupElement.popup("close") # close popup
      popupElement.on 'popupafterclose', => # have to set timeout here: JQM Chaining of popups not allowed
        popupElement.off('popupafterclose')
        if submitButton? then submitButton.off('click')
        setTimeout ( =>
          if callback? and not _.isEmpty(result) then callback result, $target
          popupElement.remove()
        ), 100
      popupElement.trigger('create')
      popupElement.popup("open", options)


    dash: (value) ->
      if _.isNull(value) or _.isUndefined(value)
        return "-"
      if value is "-" then return ""
      if value isnt "" then value else "-"

    isVisible: (element) ->
      if element.length > 0 and element.css('visibility') isnt 'hidden' and element.css('display') isnt 'none'
        true
      else
        false
    

  Util.initialize()
  Util
