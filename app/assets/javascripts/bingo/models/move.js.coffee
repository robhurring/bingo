window.Move = Backbone.Model.extend
  initialize: ->
    @id = @get 'hash'

window.Moves = Backbone.Collection.extend
  model: Move
  initialize: ->
    @url = "/games/#{Card.game_id}/moves"
