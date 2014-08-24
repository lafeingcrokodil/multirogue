// Generated by CoffeeScript 1.6.3
(function() {
  var Screen,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Screen = (function() {
    function Screen(canvas, rows, cols) {
      this.rows = rows;
      this.cols = cols;
      this.displayMap = __bind(this.displayMap, this);
      this.displayStats = __bind(this.displayStats, this);
      this.display = __bind(this.display, this);
      this.getY = __bind(this.getY, this);
      this.getX = __bind(this.getX, this);
      this.getTextWidth = __bind(this.getTextWidth, this);
      this.getFont = __bind(this.getFont, this);
      this.context = canvas.getContext('2d');
      this.charHeight = 12;
      this.charWidth = this.getTextWidth('x');
      this.width = canvas.width = cols * this.charWidth;
      this.height = canvas.height = (rows + 2) * this.charHeight;
      this.context.font = this.getFont();
      this.context.fillStyle = '#FFFFFF';
    }

    Screen.prototype.getFont = function() {
      return "" + this.charHeight + "px Courier New";
    };

    Screen.prototype.getTextWidth = function(text) {
      this.context.font = this.getFont();
      return this.context.measureText(text).width;
    };

    Screen.prototype.getX = function(col) {
      return col * this.charWidth;
    };

    Screen.prototype.getY = function(row) {
      return (row + 1) * this.charHeight;
    };

    Screen.prototype.display = function(text, row, col) {
      this.context.clearRect(this.getX(col), this.getY(row - 1) + 1, this.getTextWidth(text), this.charHeight);
      return this.context.fillText(text, this.getX(col), this.getY(row));
    };

    Screen.prototype.displayStats = function(text) {
      this.context.clearRect(0, this.getY(this.rows - 1) + 1, this.width, this.charHeight);
      return this.context.fillText(text, 0, this.getY(this.rows));
    };

    Screen.prototype.displayMap = function(map) {
      var char, col, mapRow, row, _i, _len, _results;
      _results = [];
      for (row = _i = 0, _len = map.length; _i < _len; row = ++_i) {
        mapRow = map[row];
        _results.push((function() {
          var _j, _len1, _results1;
          _results1 = [];
          for (col = _j = 0, _len1 = mapRow.length; _j < _len1; col = ++_j) {
            char = mapRow[col];
            _results1.push(this.display(char, row, col));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return Screen;

  })();

  $(document).ready(function() {
    var socket;
    socket = io.connect("http://" + location.hostname + ":" + location.port);
    socket.on('map', function(mapData) {
      var screen;
      screen = new Screen($('#screen')[0], mapData.rows, mapData.cols);
      $('#screen').css('display', 'block');
      screen.displayMap(mapData.map);
      socket.on('display', function(data) {
        return screen.display(data.char, data.row, data.col);
      });
      return socket.on('stats', function(data) {
        return screen.displayStats("HP: " + data.hp);
      });
    });
    return $(document).keydown(function(e) {
      socket.emit('key', e.which);
      return e.preventDefault();
    });
  });

}).call(this);
