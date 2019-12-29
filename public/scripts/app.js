new Vue({
  el: '#app',

  data: {
    ws: null, // our websocket
    newMsg: '', // new message to be sent to the server
    chatContent: '', // running list of chat messages displayed on the screen
    username: null, // our username
    joined: false // true if username has been filled in
  },

  created: function() {
    let self = this;
    this.ws = new WebSocket('ws://' + window.location.host + '/ws');
    this.ws.addEventListener('message', function(e) {
      let msg = JSON.parse(e.data);
      self.chatContent += `<div class="chip">${msg.username}</div>${msg.message}<br/>`;
      let element = document.getElementById('chat-messages');
      element.scrollTop = element.scrollHeight; // auto scroll to the bottom
    });
  },

  methods: {
    send: function () {
      if (this.newMsg) {
        this.ws.send(
          JSON.stringify({
            username: this.username,
            message: $('<p>').html(this.newMsg).text() // strip out html
          })
        );
        this.newMsg = ''; // reset newMsg
      }
    },

    join: function () {
      if (!this.username) {
        M.toast({html: 'Please choose a username.', displayLength: 2000});
        return;
      }
      this.username = $('<p>').html(this.username).text(); // strip out html
      this.joined = true;
    }
  }
});
