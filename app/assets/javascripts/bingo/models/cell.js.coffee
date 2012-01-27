class window.Cell extends Backbone.Model
  initialize: ->
    @id = @get 'hash'
    @url = "/games/#{Card.game_id}/cards/#{Card.id}/clicked"
    @found = false
