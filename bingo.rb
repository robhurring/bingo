require './lib/environment'

class Bingo < Sinatra::Base
  use ActiveRecord::ConnectionAdapters::ConnectionManagement
  use ActiveRecord::QueryCache
  
  use Rack::Flash, :sweep => true, :accessorize => [:notice]
  use Rack::Static, :urls => ['/css', '/images', '/js'], :root => 'public'    
  
  enable :logging, :dump_errors, :static, :sessions, :raise_errors
  set :pusher_key, Pusher.key
  set :web_root, Proc.new{ environment == :development ? '/bingo' : ''}
  disable :run

  configure do
    Log = Logger.new(File.dirname(__FILE__) + '/log/bingo.log')
  end

  get '/?' do
    erb :index
  end

# New Game
  
  get '/new_game' do
    @game = Game.new(:name => 'Bingo!', :words => [])
    erb :'game/new'
  end
  
  post '/new_game' do
    @game = Game.new(params[:game])
    
    if @game.save
      redirect url_for('/play/%s' % @game.token)
    else
      erb :'game/new'
    end  
  end
  
# New Card
  
  get '/play/:token/new_card' do |token|
    game = find_game_by_token(token)
    card = game.cards.build(:name => "Player #{game.cards.size + 1}")
    
    if card.save
      redirect url_for('/play/%s/%d' % [game.token, card.id])
    else
      flash.notice = "Whoah. Card creation failed. Try again maybe?"
      redirect url_for('/play/%s' % game.token)
    end
  end

# Card Name Change

  post '/play/:token/:id/change_name' do |token, id|
    @game, @card = find_game_and_card(token, id)
    Log.info params.inspect
    
    old_name = @card.name
    @card.update_attributes(params[:card])
    
    Pusher['game_%s' % @game.token].trigger('name_changed', {:id => @card.id, :old_name => h(old_name), :name => h(@card.name)})
    
    partial :card_name, :game => @game, :card => @card
  end

# Permalink Game

  get '/play/:token' do |token|
    @game = find_game_by_token(token) 
    
    erb :'play/index'
  end
  
  get '/play/:token/:id' do |token, id|
    @game, @card = find_game_and_card(token, id)
    
    Pusher['game_%s' % @game.token].trigger('user_joined', {:id => @card.id, :name => h(@card.name)})
    erb :'play/card'
  end
  
# Playing Words

  post '/play/:token/:id/message' do |token, id|
    game, card = find_game_and_card(token, id)
    Pusher['game_%s' % game.token].trigger('log', {:name => h(card.name), :message => Sanitize.clean(params[:message]), :player => 1})
    
    headers 'Content-Type' => 'application/json'
    {:ok => true}.to_json
  end

  post '/play/:token/:id/:row/:column' do |token, id, row, column|
    game, card = find_game_and_card(token, id)
    word = card.at(row.to_i, column.to_i)
    add = params[:add].to_i == 1
    
    if add
      card.found!(row.to_i, column.to_i)
      message = "found %s!" % word
    else
      card.unfind!(row.to_i, column.to_i)
      message = "removed %s!" % word
    end
    status = card.save
        
    Pusher['game_%s' % game.token].trigger('user_square', {
      :name => h(card.name), 
      :add => params[:add].to_i,
      :word_hash => hash(h word),
      :name_hash => hash(h card.name),
      :word => h(word)
    })
    
    if card.bingo?
      Pusher['game_%s' % game.token].trigger('log', {:name => h(card.name), :message => 'Just won the game!', :player => 0})
      Pusher['game_%s' % game.token].trigger('game_over', {:name => h(card.name)})
      
      game.winner = card.name
      game.won_at = Time.now
      game.save
    end
    
    headers 'Content-Type' => 'application/json'
    {:ok => status}.to_json
  end
  
# Global Stuffs

  not_found do
    if request.xhr?
      headers 'Content-Type' => 'application/json'
      {:status => 404, :error => env['sinatra.error']}.to_json
    else
      flash.notice = env['sinatra.error'].message
      redirect url_for('/')
    end
  end
  
private

  def find_game_and_card(token, card_id)
    game = find_game_by_token(token)
    card = game.cards.find(card_id)
    raise Sinatra::NotFound, 'This card is no longer active or in use!' unless card    
    [game, card]
  end

  def find_game_by_token(token)
    game = Game.first(:conditions => {:token => token})
    raise Sinatra::NotFound, 'This game is no longer active or in use!' unless game
    game
  end
end