define [
  'views/baseview' 
  'moment'
  'util'
  'text!templates/dayplan.tmpl'
  'views/poiview'
],(
  BaseView 
  moment
  Util
  template
  PoiView
) ->

  class DayPlanView extends BaseView

    el: $('#dayplanpage_content')

    events:
      "click .placeitem":"onPlaceItemmSelected"
      "click .poicell":"onPoiCellSelected"

    initialize: (options) =>
      @template = _.template(template)
      @projectModel = options.projectModel
#      @collection.on "reset", =>
#        @render()

      @collection.on "add change remove reset", (model, e) => 
        console.log "collection changed"
        @render()

#      $(window).on 'pagecontainershow resize', ( e, ui ) =>
#        console.log "detemine size"
#        @resizeVerticalPanels()
#        if @mySwiper?
#          @mySwiper.resizeFix() # fix swiper size
#          console.log "resizede"

    onShow: =>
      super
      $("#dayplanpage_headertitle").text Util.i18n("app_name")

#      if @collection.length is 0
#        @collection.fetch
#          reset:true
      
    onHide: ->
      super


    resizeVerticalPanels: ->
      console.log "adjustSplitPane"
      scroll(0, 0)
      screenHeight = $.mobile.getScreenHeight()
      headerHeight = $("#dayplanpage .ui-header").outerHeight()
      
      #console.log "headerHeight: " + headerHeight + ", screenHeight: " + screenHeight
      
      dividedContentHeight = (screenHeight/2) - headerHeight
      @$el.find("#upperview, #lowerview").height dividedContentHeight     

    onPlaceItemmSelected: (e) ->
      e.stopImmediatePropagation()
      e.preventDefault()
      console.log "onPlaceItemmSelected"


    onPoiCellSelected: (e) ->
      e.stopImmediatePropagation()
      e.preventDefault()
      console.log "onPoiCellSelected"
      id = $(e.currentTarget).data("id")
      
      model = @collection.get(id)
      #@poiElement.el = @$el.find(".dayplan-table")
      
      #@poiView.model = model

      
      #@poiElement.el = $(e.currentTarget)
      #element = @poiView.render()
      #html = new PoiView({model:model}).render().el
      #console.log $(html).html()

      Util.showView new PoiView({model:model, collection:@collection}).render(), undefined, (e, selectedElement) =>
        if selectedElement?
          if $(selectedElement.currentTarget).hasClass("editPlaceButton")
            Util.showView new PoiView({model:model, collection:@collection}).render("edit"), undefined, (e) =>

              console.log "ji"
              console.log e

      #table = @$el.find(".ui-body")
      #$(e.currentTarget).html element
      #element.append




    render: ->

      #upperView = @$el.find("#upperview")
      #lowerView = @$el.find("#lowerview")
      
      @$el.html @template
        'Util': Util
        collection:@collection
        moment:moment
        projectModel:@projectModel
        #startdate:"2015-06-18"
        #enddate:"2015-06-30"


#      if @mySwiper?
#        @mySwiper.destroy()
#        @mySwiper = null

#      if not @mySwiper?
#      @mySwiper = @$el.find('.swiper-container').swiper
#        #mode:'horizontal'
#        slidesPerView: 4
#        paginationClickable: true
#        spaceBetween: 30
      




#      swiperContent = @$el.find(".swiper-wrapper")


#      swiperContent.append @template_test
#        'Util': Util

      

#      swiperContent.append @template_lower
#        'Util': Util
#        collection:@collection
#        moment:moment
#        startdate:"2015-06-18"
#        enddate:"2015-06-30"


#      @$el.html @template
#        'Util': Util
#        collection:@collection
#        moment:moment
#        startdate:"2015-06-18"
#        enddate:"2015-06-30"

      @$el.enhanceWithin()
      @

  DayPlanView
