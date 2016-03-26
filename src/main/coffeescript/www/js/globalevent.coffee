# Define GlobalEvent implementing singleton pattern
define 'globalevent', ['underscore', 'backbone'], (_, Backbone)->
  GlobalEvent =  _.extend({}, Backbone.Events)

  GlobalEvent
 