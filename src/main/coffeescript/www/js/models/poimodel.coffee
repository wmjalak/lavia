define [
  'backbone'
  'moment'
], (
  Backbone
  moment
) ->
 
  class PoiModel extends Backbone.Model
    idAttribute: "_id"
    url:  ""

    isNew: ->
      not @has("_id")

    types: ->
      ["PLACE", "FOOD", "ACCOMODATION"]

    getDate: (value) ->
      moment(@get(value)).format("yyyy-MM-dd")


  PoiModel
