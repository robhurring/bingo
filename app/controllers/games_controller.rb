class GamesController < ApplicationController
  respond_to :html
  respond_to :json, :only => [:moves]

  def new
    @game = Game.new(name: 'Bingo!', words: [])
    respond_with @game
  end

  def create
    @game = Game.new params[:game]

    if @game.save
      flash.notice = 'Game Created!'
      redirect_to @game
    else
      render :new
    end
  end

  def show
    @game = Game.find params[:id]
    respond_with @game
  end

  def moves
    game = Game.find params[:id]
    moves = []

    game.cards.each do |card|
      card.found.each do |word|
        moves << Move.new(card.name, word, true).to_h
      end
    end

    respond_with moves
  end
end
