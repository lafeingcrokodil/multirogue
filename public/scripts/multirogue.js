let MultiRogue = new Vue({
  el: '#multirogue',

  data: {
    joined: false, // true if we have joined the game
    name: null, // name of our adventurer
    rows: [] // rows of characters displayed on the screen
  },

  methods: {
    display: function({c, x, y}) {
      let row = this.rows[y]; // in the yth row...
      row.splice(x, 1, c); // replace the xth character with c
      Vue.set(this.rows, y, row);
    },

    displayLevel: function({map}) {
      let rows = [];
      let row = [];
      let c;
      for (let i = 0; i < map.length; i++) {
        c = map.charAt(i);
        if (c === '\n') {
          rows.push(row);
          row = [];
        } else {
          row.push(c);
        }
      }
      this.rows = rows;
    },

    handleEvent: function(e) {
      let events = JSON.parse(e.data);
      for (event of events) {
        switch (event.name) {
          case 'display':
            this.display(JSON.parse(event.data));
            break;
          case 'level':
            this.displayLevel(JSON.parse(event.data));
            break;
          default:
            console.error('unknown event:', event.name);
        }
      }
    },

    fireEvent: function(name, data) {
      this.ws.send(JSON.stringify({
        name: name,
        data: JSON.stringify(data)
      }));
    },

    join: function() {
      if (!this.name) {
        alert('Please enter a name between 1 and 16 characters.');
        return;
      }

      // connect to server
      this.ws = new WebSocket('ws://' + window.location.host + '/ws?name=' + this.name);
      this.ws.addEventListener('message', this.handleEvent.bind(this));

      this.joined = true;
    }
  }
});
