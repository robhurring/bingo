window.PlayerView = Backbone.View.extend
  tagName: 'li'

  render: ->
    ($ @el).text @model.get('info').name
    @

window.PlayersView = Backbone.View.extend
  tagName: 'div'

  initialize: ->
    _.bindAll @, 'render'
    @template = ($ 'script[name=players-template]').html().trim()
    @collection.bind 'add', @render
    @collection.bind 'remove', @render
    @collection.bind 'reset', @render

  render: ->
    ($ @el).html $.mustache @template, {count: @collection.length}

    @collection.each (player) ->
      @.$('#whos_playing').append new PlayerView({model: player}).render().el

    @
