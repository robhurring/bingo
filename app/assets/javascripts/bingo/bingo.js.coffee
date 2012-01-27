class Bingo
  constructor: (pusher) ->
    @pusher = pusher
    @moves = new Moves()
    @players = new Players()
    @initViews()
    @initPusher()

  initViews: ->
    @boardView = new BoardView {el: '#board', collection: @moves}
    @playersView = new PlayersView {el: '#players', collection: @players}

    @boardView.render()
    @playersView.render();

  startGame: ->
    @moves.fetch()

  initPusher: ->
    @channel = @pusher.subscribe "presence-#{Card.game_id}"
    @channel.bind 'pusher:subscription_succeeded', @subscriptionSucceeded
    @channel.bind 'pusher:member_added', @playerJoined
    @channel.bind 'pusher:member_removed', @playerLeft
    @channel.bind 'cell_clicked', @cellClicked

  subscriptionSucceeded: (data) =>
    data.each (info) =>
      player = new Player(info)
      @players.add player

  playerJoined: (data) =>
    player = new Player(data)
    @players.add player
    @moves.fetch()

  playerLeft: (data) =>
    player = @players.get(data.id)
    @players.remove player
    @moves.fetch()

  cellClicked: (data) =>
    move = new Move(data)
    @moves.add move

$ ->
  unless Card?
    return

  if PUSHER_DEBUG
    WEB_SOCKET_DEBUG = true
    Pusher.log = (message) ->
      if window.console && window.console.log
        window.console.log message

  Pusher.channel_auth_endpoint = "/games/#{Card.game_id}/cards/#{Card.id}/join"
  pusher = new Pusher PUSHER_KEY

  window.bingo = new Bingo pusher
  bingo.startGame()
