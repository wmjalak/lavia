define [
  'backbone'
],(
  Backbone
) -> 

  class ProjectModel extends Backbone.Model
    idAttribute: "_id"
    url:  ""

    defaults:
      "name":""
      "startdate":""
      "enddate":""

  ProjectModel
