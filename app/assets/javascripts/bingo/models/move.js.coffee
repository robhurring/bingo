class window.Move extends Backbone.Model
  initialize: ->
    @id = @get 'hash'

class window.Moves extends Backbone.Collection
  model: Move
  initialize: ->
    @url = "/games/#{Card.game_id}/moves"
