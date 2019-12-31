let MultiRogue = new Vue({
  el: '#multirogue',

  data: {
    rows: [] // rows of characters displayed on the screen
  },

  created: function() {
    for (let y = 0; y < 24; y++) {
      let row = [];
      for (let x = 0; x < 80; x++) {
        row.push('.');
      }
      this.rows.push(row);
    }
    
    this.ws = new WebSocket('ws://' + window.location.host + '/ws');
    this.ws.addEventListener('message', this.handleEvent.bind(this));
  },

  methods: {
    display: function({c, x, y}) {
      let row = this.rows[y]; // in the yth row...
      row.splice(x, 1, c); // replace the xth character with c
      Vue.set(this.rows, y, row);
    },

    handleEvent: function(e) {
      let event = JSON.parse(e.data);
      switch (event.name) {
        case 'display':
          this.display(JSON.parse(event.data));
      }
    },

    fireEvent: function(name, data) {
      this.ws.send(JSON.stringify({
        name: name,
        data: JSON.stringify(data)
      }));
    }
  }
});
