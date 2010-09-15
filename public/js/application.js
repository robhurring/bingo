$(document).ready(function()
{
  $.metadata.setType('attr', 'data');
  $.bingo.init();
  
// // Pusher
// 
//   if(Application.card)
//   {
//     WEB_SOCKET_DEBUG = true;
//     Pusher.log = function()
//     {
//       if (window.console) window.console.log.apply(window.console, arguments);
//     };
// 
//     var pusher = new Pusher(Application.pusher_key, 'game_'+Application.token);
//     pusher.bind('log', function(data)
//     {
//       var message = '<strong>' + data.name + ':</strong> ' + data.message;
//       if(parseInt(data.player) == 0)
//         message = '<small>' + message + '</small>';
//         
//       $('#messages').prepend(message + '<br/>');
//     });
//     
//     pusher.bind('game_over', function(data)
//     {
//       Application.game_over = true;
//     });
//   }
// 
// // Chat
// 
//   $('#send_message').keypress(function(e)
//   {
//     var url = Application.web_root + '/play/' + Application.token + '/' + Application.card + '/message';
//     if(e.keyCode == 13)
//     {
//       $.post(url, {message: $(this).val()});
//       $(this).val('');
//     }
//   });
// 
// // Selecting Words
// 
//   $('.square').click(function()
//   {
//     if(Application.game_over)
//       return;
//       
//     var self = $(this);
//     var data = self.metadata();
//   
//     var url = Application.web_root + '/play/' + Application.token + '/' + Application.card + '/' + data.row + '/' + data.column;
//     var add = !self.hasClass('found');
//   
//     self.find('.indicator').show();
//     
//     $.post(url, {"add": (add ? 1 : 0)}, function(data, status)
//     {
//       self.find('.indicator').hide();
//       if(add)
//         self.addClass('found');
//       else
//         self.removeClass('found');
//     });
//   });
// 
// // Hovers
//   
//   $('.square').mouseover(function(){ $(this).addClass('hover') });
//   $('.square').mouseout(function(){ $(this).removeClass('hover') });
//   
// // Name Changes
//   
//   $('.card_name_toggle').live('click', function()
//   {
//     if(Application.game_over)
//       return;
//     
//     $('#name_input').toggle();
//     $('#name_text').toggle();
//     return false;
//   });
//   
//   $('#submit_name_change').live('click', function()
//   {
//     if(Application.game_over)
//       return;
//     
//     var url = Application.web_root + '/play/' + Application.token + '/' + Application.card + '/change_name';
//     var name = $('#card_name').val();
//     var indicator = $(this).parent().parent().parent().find('.indicator');
// 
//     indicator.show();    
//     $.post(url, {"card[name]": name}, function(data)
//     {
//       indicator.hide();
//       $('#card_name_form').replaceWith(data);
//     });
//   });

});
