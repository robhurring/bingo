# controls the individual cell. it tracks if the cell is highlighted or not, and which users
# are holding this cell as well as our current user
class window.CellView extends Backbone.View
  className: 'cell'
  events:
    'click': 'clicked'

  initialize: ->
    _.bindAll @, 'clicked', 'modelFoundStateChanged', 'scanMoves', 'handleMove'
    @url = "/games/#{Card.game_id}/cards/#{Card.id}/#{@model.get 'hash'}"
    @template = ($ 'script[name=cell-template]').html().trim()
    @model.bind 'change:found', @modelFoundStateChanged
    @collection.bind 'reset', @scanMoves
    @collection.bind 'add', @handleMove
    @users = []

  render: ->
    $(@el).html $.mustache @template, @model.toJSON()
    @

  # update our model when clicked and push to the server
  clicked: ->
    this.$('.indicator').show()
    @model.save {},
      error: (model, response) =>
        @.$('.indicator').hide()
      success: (model, response) =>
        @.$('.indicator').hide()

  # when our model changes
  modelFoundStateChanged: ->
    ($ @el).toggleClass 'found', @model.get('found')

  # scan all moves and setup our board
  scanMoves: ->
    @collection.each (move) =>
      @handleMove move

  # highlights the cell if it is our move, otherwise we add the other
  # players to our cell detail
  handleMove: (move) ->
    [my_name, my_hash, move_name, move_hash] =
      [Card.name, @model.get('hash'), move.get('name'), move.get('hash')]

    # handle my own state
    if my_name == move_name && my_hash == move_hash
      @model.set {found: move.get('found') }
    else
      # display others in the cell
      if move_name != my_name && move_hash == my_hash
        if move.get('found')
          @users.push move_name unless _.include(@users, move_name)
        else
          @users = _.without(@users, move_name)

        @.$('.users').html @users.join('<br/>')
