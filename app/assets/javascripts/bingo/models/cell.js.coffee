window.Cell = Backbone.Model.extend
  initialize: ->
    @id = @get 'hash'
    @url = "/games/#{Card.game_id}/cards/#{Card.id}/clicked"
    @found = false
