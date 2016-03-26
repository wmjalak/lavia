define [
  'views/baseview'
  'util'
  'text!templates/basicinfo.tmpl'
  'text!templates/reviewsummary.tmpl'
  'text!templates/designers.tmpl'
  'text!templates/foremen.tmpl'
  'text!templates/specialplans.tmpl'
  'text!templates/review.tmpl'
  'text!templates/reviewedit.tmpl'
  'text!templates/swiper.tmpl'
  'models/sitemodel'
  'swiper'
], (
  BaseView
  Util
  templateBasicInfo
  templateReviewSummary
  templateReviewDesigners
  templateReviewForemen
  templateReviewSpecialPlans
  templateReview
  templateReviewEdit
  swiperTemplate
  SiteModel
  Swiper
) ->

  class ItemView extends BaseView
    el: $('#itemview_content')

    events:
      'click .edit-review':'onEditReviewSelected'
      'click #switch_review_button':'onSwitchReviewSelected'
      'click #cancel_reviewedit_button':'onCancelReviewEditSelected'

    initialize: (options) =>
      @templateBasicInfo = _.template(templateBasicInfo)
      @templateReviewSummary = _.template(templateReviewSummary)
      @templateReview = _.template(templateReview)
      @templateReviewEdit = _.template(templateReviewEdit)
      @templateReviewDesigners = _.template(templateReviewDesigners)
      @templateReviewForemen = _.template(templateReviewForemen)
      @templateReviewSpecialPlans = _.template(templateReviewSpecialPlans)
      @swiperTemplate = _.template(swiperTemplate)

      
      @model = new SiteModel 
        "id": 103,
        "title": "Default model Item 1",
        "status": "SENT",
        "created": "2014-10-01T07:00:00+02:00",
        "type": "travelExpence",
        "expenceValue": "100",
        "travelDistance":"85",
        "travelDuration":"1h 20min",
        "lat":"60.229462",
        "lng":"24.869650"

      $(window).on 'pagecontainershow resize', ( e, ui ) =>
        if e.type is "pagecontainershow" and @pageId() is "itempage"
          @mySwiper.resizeFix() # fix swiper size
        #@adjustSplitPane()

    onShow: =>
      super

      $("#itemview_headertitle").text @model.get('permitCode')
      @mySwiper = $('.swiper-container').swiper
        mode:'horizontal'
        onSlideChangeEnd: (swiper) =>
          $("#auditSummaryPageIndicator").attr("src","img/pagecontrol_"+swiper.activeIndex+".png")
          console.log swiper.activeIndex
          #$("#navbar a").removeClass "ui-btn-active"
          #$("##{@navbarButtonIds[swiper.activeIndex]}").addClass "ui-btn-active"

    onHide: ->
      super
      @mySwiper.destroy()

    adjustSplitPane: ->
      console.log "adjustSplitPane"
      scroll(0, 0)
      screenHeight = $.mobile.getScreenHeight()
      headerHeight = $("#itempage .ui-header").outerHeight()
      
      console.log "headerHeight: " + headerHeight + ", screenHeight: " + screenHeight
      
      dividedContentHeight = (screenHeight/2) - headerHeight
      @$el.find("#upperview, #lowerview").height dividedContentHeight     

    onSwitchReviewSelected: (e) =>
      e.stopImmediatePropagation()
      e.preventDefault()

      $target = $(e.currentTarget)
      $target.toggleClass "switch_selected"
      
      @$el.find(".non-property-tr").toggle()
      @$el.find(".property-tr").fadeToggle()

    onEditReviewSelected: (e) ->
      e.stopImmediatePropagation()
      e.preventDefault()

      @$el.find("#lowerview").hide()
      
      editView = @$el.find("#editview")
      editView.show()
      editView.html @templateReviewEdit
        'Util': Util
        model:@model
      
      @$el.enhanceWithin()
      
    onCancelReviewEditSelected: (e) =>  
      e.stopImmediatePropagation()
      e.preventDefault()      

      @$el.find("#editview").hide()
      @$el.find("#lowerview").show()

    render: =>
      console.log "render"
      upperView = @$el.find("#upperview")
      lowerView = @$el.find("#lowerview")
      
      upperView.html @templateBasicInfo
        'Util': Util
        model:@model


      lowerView.html @swiperTemplate # load swiper template
        'Util': Util

      swiperContent = @$el.find(".swiper-wrapper")

      swiperContent.append @templateReviewSummary
        'Util': Util
        model:@model

      swiperContent.append @templateReview
        'Util': Util
        model:@model

      swiperContent.append @templateReviewSpecialPlans
        'Util': Util
        model:@model

      swiperContent.append @templateReviewDesigners
        'Util': Util
        model:@model

      lowerView.find(".property-tr").hide()

      @$el.enhanceWithin()
      @


  ItemView
