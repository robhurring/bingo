(function($){

$.extend(
{
  bingo: {
    settings: {},
    pusher: null,
    
    init: function()
    {
      var defaults = {
        web_root: '/bingo',
        token: '',
        card: '',
        name_hash: '',
        game_over: false,
        pusher_key: '',
        debug: true,
        inputs: {
          name: '#card_name',
          name_form: '#card_name_form'
        }
      };
      
      this.settings = $.extend(defaults, this.settings);      
      
      setup_pusher();
      setup_events();
    },
    
    log: function(data)
    {
      var message = '<strong>' + data.name + ':</strong> ' + data.message;
      if(parseInt(data.player) == 0)
        message = '<small>' + message + '</small>';

      $('#messages').prepend(message + '<br/>');
    },
    
    game_over: function(data)
    {
      this.settings.game_over = true;
      $('#game_over').html('<span>Game was won by ' + data.name + '!</span>').fadeIn('slow');
      $('.card').addClass('game_over');
    },
    
    game_url: function(card)
    {
      var url = this.settings.web_root + '/play/' + this.settings.token
      if(card)
        url += '/' + this.settings.card;
      return url;
    },
    
    click_square: function(square)
    {
      if(this.settings.game_over)
        return false;

      var square = $(square);
      var data = square.metadata();

      var url = this.game_url(true) + '/' + data.row + '/' + data.column
      var add = !square.hasClass('found');

      square.find('.indicator').show();

      $.post(url, {"add": (add ? 1 : 0)}, function(data, status)
      {
        square.find('.indicator').hide();
        if(add)
          square.addClass('found');
        else
          square.removeClass('found');
      });
    },
    
    change_name: function()
    {
      if(this.settings.game_over)
        return false;

      //console.log(this.settings);
    
      var url = this.game_url(true) + '/change_name';
      var input = $(this.settings.inputs.name);
      
      var indicator = input.parent().parent().find('.indicator');

      indicator.show();    
      $.post(url, {"card[name]": input.val()}, function(data)
      {
        indicator.hide();
        $(this.settings.inputs.name_form).replaceWith(data);
      });      
    },
    
    user_square_event: function(data)
    {      
      var squares = $('.square');
      var add = (parseInt(data.add) == 1);
      var message = (add ? 'found ' : 'removed ') + data.word + '!';
      
      if(data.name_hash != this.settings.name_hash)
      {
        // add player name to our board
        $('.square').each(function(i, element)
        {
          var element = $(element);
          var meta = element.metadata();

          if(meta.hash == data.word_hash)
          {
            if(add)
              element.find('.users').append('<small id="' + data.name_hash + '">' + data.name + '</small>');
            else
              element.find('.users').find('#' + data.name_hash).remove();
          }
        });
      }
        
      this.log({'name': data.name, 'message': message, 'player': 0});
    },
    
    send_message: function(message, callback) 
    {
      var url = this.game_url(true) + '/message';
      $.post(url, {'message': message}, callback);      
    },
    
    user_joined_event: function(data)
    {
      // console.log(data);
      
      var already_in_list = $('#whos_playing li#player-' + data.id).length > 0
      // console.log("In? " + already_in_list + "\n" + data.name);
      
      if(!already_in_list)
      {
        $('#whos_playing').append('<li id="player-' + data.id + '">' + data.name + '</li>');
        this.log({'name': data.name, 'message': 'has just joined!', 'player': 0});
      }
    },
    
    name_changed_event: function(data)
    {
      $('#whos_playing li#player-' + data.id).html(data.name);
      this.log({'name': data.old_name, 'message': 'Is now known as ' + data.name});
    }
  } // EOBingo  
});

function setup_events()
{
  $('.square').click(function(){ $.bingo.click_square(this) });
  $('.square').mouseover(function(){ square_over(this); });
  $('.square').mouseout(function(){ square_out(this); });
  $('#submit_name_change').live('click', function(){ $.bingo.change_name(); });
  
  $('.card_name_toggle').live('click', function()
  { 
    $('#name_input').toggle();
    $('#name_text').toggle();
    return false;
  }); 
  
  $('#send_message').keypress(function(e)
  {
    if(e.keyCode == 13)
    {
      $('#message_indicator').show();
      $.bingo.send_message($(this).val(), function()
      {
        $('#message_indicator').hide();
      });
      $(this).val('');
    }
  });
}

function setup_pusher()
{
  if($.bingo.settings.debug)
  {
    WEB_SOCKET_DEBUG = true;  
    Pusher.log = function(){ if (window.console) window.console.log.apply(window.console, arguments); };
  }
    
  $.bingo.pusher = new Pusher($.bingo.settings.pusher_key, 'game_' + $.bingo.settings.token);
  
  $.bingo.pusher.bind('log', function(data){ $.bingo.log(data); });
  $.bingo.pusher.bind('game_over', function(data){ $.bingo.game_over(data); });
  $.bingo.pusher.bind('user_square', function(data){ $.bingo.user_square_event(data); });
  $.bingo.pusher.bind('user_joined', function(data){ $.bingo.user_joined_event(data); });
  $.bingo.pusher.bind('name_changed', function(data){ $.bingo.name_changed_event(data); });
}

function square_over(element)
{
  $(element).addClass('hover');
}

function square_out(element)
{
  $(element).removeClass('hover');
}

})(jQuery);