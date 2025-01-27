$( document ).ready(function() {
  Shiny.addCustomMessageHandler('apply_gradient', function(message) {

  var colors = message.colors;

  document.body.style.background = 'linear-gradient(135deg, ' + colors.join(', ') + ')';
  document.body.style.backgroundAttachment = 'fixed';
});
});
