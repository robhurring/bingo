class CardsController < ApplicationController
  protect_from_forgery :except => :authorize
  respond_to :json, :only => [:clicked]

  def new
    game = Game.find(params[:game_id])
    card = game.cards.build(name: (session[:name] || "Player #{game.cards.size + 1}"))

    if card.save
      redirect_to game_card_path(game, card)
    else
      flash[:notice] = "Whoah. Card creation failed. Try again maybe?"
      redirect_to game_path(game)
    end
  end

  def show
    @game = Game.find(params[:game_id])
    @card = @game.cards.find(params[:id])

    render :show
  end

  def clicked
    game = Game.find params[:game_id]
    card = game.cards.find params[:id]
    row, col = params[:row], params[:col]
    found = true

    if card.has?(row, col)
      card.unfind! row, col
      found = false
    else
      card.found! row, col
    end

    move = Move.new(card.name, card.at(row, col), found)
    Pusher["presence-#{game.id}"].trigger! 'cell_clicked', move.to_h

    card.save

    respond_with card, :status => 200
  end

  def join
    game = Game.find params[:game_id]
    card = game.cards.find params[:id]

    response = Pusher[params[:channel_name]].authenticate(params[:socket_id],
    {
      :user_id => card.id,
      :user_info => {
        :name => card.name
      }
    })

    render :json => response
  end
end
