let MultiRogue = new Vue({
  el: '#multirogue',

  data: {
    joined: false, // true if we have joined the game
    name: null, // name of our adventurer
    map: [] // lines of characters displayed on the screen
  },

  methods: {
    display: function({c, x, y}) {
      let line = this.map[y]; // in the yth line...
      line.splice(x, 1, c); // replace the xth character with c
      Vue.set(this.map, y, line);
    },

    displayLevel: function({map}) {
      let newMap = [];
      let line = [];
      let c;
      for (let i = 0; i < map.length; i++) {
        c = map.charAt(i);
        if (c === '\n') {
          newMap.push(line);
          line = [];
        } else {
          line.push(c);
        }
      }
      this.map = newMap;
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

      document.addEventListener('keydown', this.handleKeydown.bind(this));
    },

    handleKeydown: function(event) {
      switch (event.key) {
        case 'ArrowLeft':
        case 'h':
        case '4':
          this.fireEvent('move', {dx: -1, dy: 0});
          break;
        case 'ArrowRight':
        case 'l':
        case '6':
          this.fireEvent('move', {dx: 1, dy: 0});
          break;
        case 'ArrowUp':
        case 'k':
        case '8':
          this.fireEvent('move', {dx: 0, dy: -1});
          break;
        case 'ArrowDown':
        case 'j':
        case '2':
          this.fireEvent('move', {dx: 0, dy: 1});
          break;
        case 'Home':
        case 'y':
        case '7':
          this.fireEvent('move', {dx: -1, dy: -1});
          break;
        case 'PageUp':
        case 'u':
        case '9':
          this.fireEvent('move', {dx: 1, dy: -1});
          break;
        case 'End':
        case 'b':
        case '1':
          this.fireEvent('move', {dx: -1, dy: 1});
          break;
        case 'PageDown':
        case 'n':
        case '3':
          this.fireEvent('move', {dx: 1, dy: 1});
          break;
        case 'Clear':
        case '.':
        case '5':
          this.fireEvent('move', {dx: 0, dy: 0});
          break;
        default:
          console.error('unsupported key press:', event.key);
          return; // don't prevent default for unrecognized keys
      }
      event.preventDefault();
    }
  }
});
