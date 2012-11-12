// Generated by CoffeeScript 1.3.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Medibot.Models || (Medibot.Models = {});

  Medibot.Models.Joystick = Backbone.Model.extend({
    defaults: {
      sensitivity: 0.05,
      sources: ['camera', 'motors'],
      sourceOn: 0,
      last: {
        x: 0,
        y: 0
      },
      pos: {
        x: 0,
        y: 0
      }
    },
    initialize: function() {
      return this.on('change', function() {
        var last, pos, sens;
        last = this.get('last');
        sens = this.get('sensitivity');
        pos = this.get('pos');
        if ((pos.x < last.x - sens) || (pos.y < last.y - sens) || (pos.x > last.x + sens) || (pos.y > last.y + sens)) {
          Medibot.socket.emit("" + (this.source()) + ":move", pos);
          return this.set('last', pos);
        }
      });
    },
    source: function() {
      return this.get('sources')[this.get('sourceOn')];
    }
  });

  Medibot.Models.Compass = Backbone.Model.extend({
    defaults: {
      heading: 0,
      bearing: 'North',
      raw: {
        x: 0,
        y: 0,
        z: 0
      },
      scaled: {
        x: 0,
        y: 0,
        z: 0
      }
    }
  });

  Medibot.Models.Scanner = Backbone.Model.extend({
    defaults: {
      steps: 20,
      range: [0, 180],
      degrees: 0
    }
  });

  Medibot.Models.Ping = Backbone.Model.extend({
    defaults: {
      distance: 0,
      min: 0,
      max: 140
    }
  });

  Medibot.Models.Sonar = Backbone.Model.extend({
    defaults: {
      ping: {},
      scanner: {}
    },
    initialize: function() {
      var _this = this;
      this.set('scanner', new Medibot.Models.Scanner);
      this.set('ping', new Medibot.Models.Ping);
      this.get('scanner').on('change', function() {
        return _this.trigger('change');
      });
      return this.get('ping').on('change', function() {
        return _this.trigger('change');
      });
    }
  });

  Medibot.Models.Notification = Backbone.Model.extend({
    defaults: {
      body: '',
      type: 'default',
      timestamp: Date.now(),
      priority: 0
    }
  });

  Medibot.Models.Motor = Backbone.Model.extend({
    defaults: {
      min: 0,
      max: 255,
      value: 0
    },
    progress: function() {
      return this.get('value') / this.get('max');
    }
  });

  Medibot.Models.Sensor = Backbone.Model.extend({
    defaults: {
      min: 410,
      max: 565
    },
    value: 0,
    progress: function() {
      return this.get('value') / this.get('max');
    }
  });

  Medibot.Collections || (Medibot.Collections = {});

  Medibot.Collections.Notifications = Backbone.Collection.extend({
    model: Medibot.Models.Notification
  });

  Medibot.Collections.Sensors = Backbone.Collection.extend({
    model: Medibot.Models.Sensor
  });

  Medibot.Views || (Medibot.Views = {});

  Medibot.Views.Base = Backbone.View.extend({
    showFor: function(seconds, isPersistent) {
      var _this = this;
      this.show(this.animation, function() {
        var timer;
        timer = setTimeout(function() {
          return _this.hide();
        }, seconds * 1000);
        _this.$el.on('mouseover', function() {
          return clearTimeout(timer);
        });
        return _this.$el.on('mouseleave', function() {
          return _this.hide();
        });
      });
      return this;
    },
    renderChild: function(view, $div) {
      $div || ($div = this.$el);
      return $div.append(view.render().el);
    },
    toggle: function() {
      if (this.isVisible) {
        return this.hide();
      } else {
        return this.show();
      }
    },
    show: function(animation, callback) {
      var _this = this;
      this.animation = animation || this.animation;
      this.animate(this.animation);
      return this.on('animation:complete', function() {
        _this.isVisible = true;
        _this.trigger('visibility:showing');
        _this.$el.addClass('active');
        if (callback) {
          return callback();
        }
      });
    },
    hide: function(animation, callback) {
      var _this = this;
      if (animation == null) {
        animation = this.reverseAnimation(this.animation);
      }
      if (this.isVisible && !this.isAnimating) {
        this.animate(animation);
        return this.on('animation:complete', function() {
          _this.isVisible = false;
          _this.$el.removeClass('active');
          _this.trigger('visibility:hidden');
          if (callback) {
            return callback();
          }
        });
      }
    },
    transition: function(transition) {
      var _this = this;
      this.transition = transition || this.transition;
      this.trigger('transition:started');
      return this.$el.transitionCSS(transition, function() {
        _this.$el.addClass('active');
        return _this.trigger('transition:complete');
      });
    },
    animate: function(animation) {
      var _this = this;
      if (!this.isAnimating) {
        this.isAnimating = true;
        this.trigger('animation:started');
        return this.$el.animateCSS(animation, function() {
          _this.isAnimating = false;
          return _this.trigger('animation:complete');
        });
      }
    },
    reverseAnimation: function(str) {
      var item, matchList, newStr, reverseList, _i, _len;
      if (str == null) {
        str = '';
      }
      matchList = ['Out', 'In', 'Down', 'Up', 'Right', 'Left'];
      reverseList = ['In', 'Out', 'Up', 'Down', 'Left', 'Right'];
      newStr = str;
      for (_i = 0, _len = matchList.length; _i < _len; _i++) {
        item = matchList[_i];
        if (str.indexOf(item) !== -1) {
          newStr = newStr.replace(item, reverseList[_i]);
        }
      }
      return newStr;
    }
  });

  Medibot.Views.RaphaelBase = Backbone.View.extend({
    tagName: 'div',
    colors: {
      bg: 'rgb(26, 56, 59)',
      highlight: 'rgb(64, 215, 220)',
      highlight2: 'rgba(255, 102, 124)',
      transparent: 'rgba(64, 215, 220, 0.1)',
      invisible: 'rgba(64, 215, 220, 0)',
      warning: 'rgba(244, 54, 6)',
      glow: 'rgb(35,41,37)'
    },
    initialize: function(options) {
      this.options = options != null ? options : {};
      _.bindAll(this, 'draw');
      this.model.on('change', this.draw);
      return _.defaults(this.options, {
        animation: "<>",
        lineWidth: 8,
        digit: false,
        label: false
      });
    },
    resize: function(width, height) {
      this.paper.clear();
      this.remove();
      this.options.width = width;
      this.options.height = height;
      return this.render();
    },
    render: function() {
      if (this.options.label) {
        this.$el.append("<h3 class='section-label'>" + this.options.label + "</h3>");
      }
      if (this.options.radius) {
        this.center = this.options.radius + this.options.lineWidth;
        this.paper = Raphael(this.el, this.center * 2, this.center * 2);
      } else {
        this.cx = (this.options.width / 2) + (this.options.lineWidth * 2);
        this.cy = (this.options.height / 2) + (this.options.lineWidth * 2);
        this.paper = Raphael(this.el, this.options.width, this.options.height);
      }
      if (this.options.digit) {
        this.$el.append('<p class="digit">0</p>');
        this.$digit = this.$('.digit');
      }
      return this.paper.customAttributes.arc = function(cx, cy, value, total, R) {
        var a, alpha, path, x, y;
        alpha = 360 / total * value;
        a = (90 - alpha) * Math.PI / 180;
        x = cx + R * Math.cos(a);
        y = cy - R * Math.sin(a);
        if (total === value) {
          path = [["M", cx, cy - R], ["A", R, R, 0, 1, 1, cx - 0.01, cy - R]];
        } else {
          path = [["M", cx, cy - R], ["A", R, R, 0, +(alpha > 180), 1, x, y]];
        }
        return {
          path: path
        };
      };
    }
  });

  Medibot.Views || (Medibot.Views = {});

  Medibot.Views.BlockGraph = (function(_super) {

    __extends(BlockGraph, _super);

    function BlockGraph() {
      return BlockGraph.__super__.constructor.apply(this, arguments);
    }

    BlockGraph.prototype.className = 'block-graph section';

    BlockGraph.prototype.initialize = function(options) {
      this.options = options != null ? options : {};
      BlockGraph.__super__.initialize.apply(this, arguments);
      this.options.spacing = this.options.spacing || 4;
      return this.options.direction = this.options.direction || 'right';
    };

    BlockGraph.prototype.draw = function() {
      var block, col, colorCond, eraseCond, limit, opacity, progress, row, _i, _ref, _results;
      progress = this.model.progress();
      _results = [];
      for (row = _i = 0, _ref = this.options.rows - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; row = 0 <= _ref ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (col = _j = 0, _ref1 = this.options.cols - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; col = 0 <= _ref1 ? ++_j : --_j) {
            block = this.blocks[row][col];
            opacity = block.attr('fill-opacity');
            if (this.options.direction === 'up') {
              limit = Math.floor(this.options.rows - (progress * this.options.rows));
              colorCond = opacity < 1 && row >= limit;
              eraseCond = opacity > 0 && row <= limit;
            }
            if (this.options.direction === 'right') {
              limit = Math.floor(progress * this.options.cols);
              colorCond = opacity < 1 && col <= limit;
              eraseCond = opacity > 0 && col >= limit;
            }
            if (colorCond) {
              _results1.push(block.animate({
                'fill-opacity': 1
              }, 200, this.options.animation));
            } else if (eraseCond) {
              _results1.push(block.animate({
                'fill-opacity': 0
              }, 200, this.options.animation));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    BlockGraph.prototype.render = function() {
      var block, blockHeight, blockWidth, col, row, x, y, _i, _j, _k, _len, _ref, _ref1, _ref2;
      BlockGraph.__super__.render.apply(this, arguments);
      this.blocks = new Array(this.options.rows);
      _ref = this.blocks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        block = _ref[_i];
        this.blocks[_i] = new Array(this.options.cols);
      }
      blockWidth = Math.floor(this.options.width / this.options.cols) - this.options.lineWidth - this.options.spacing;
      blockHeight = Math.floor(this.options.height / this.options.rows) - this.options.lineWidth - this.options.spacing;
      y = this.options.spacing;
      for (row = _j = 0, _ref1 = this.options.rows - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; row = 0 <= _ref1 ? ++_j : --_j) {
        x = this.options.spacing;
        for (col = _k = 0, _ref2 = this.options.cols - 1; 0 <= _ref2 ? _k <= _ref2 : _k >= _ref2; col = 0 <= _ref2 ? ++_k : --_k) {
          block = this.paper.rect(x, y, blockWidth, blockHeight).attr({
            stroke: this.colors.bg,
            fill: this.colors.highlight,
            'fill-opacity': 0,
            'stroke-width': this.options.lineWidth
          });
          this.blocks[row][col] = block;
          x += blockWidth + this.options.spacing;
        }
        y += blockHeight + this.options.spacing;
      }
      return this;
    };

    return BlockGraph;

  })(Medibot.Views.RaphaelBase);

  Medibot.Views || (Medibot.Views = {});

  Medibot.Views.CircularGraph = (function(_super) {

    __extends(CircularGraph, _super);

    function CircularGraph() {
      return CircularGraph.__super__.constructor.apply(this, arguments);
    }

    CircularGraph.prototype.className = 'circular-graph section';

    CircularGraph.prototype.draw = function() {
      var max, value;
      value = this.model.get('value');
      max = this.model.get('max');
      if (!(value > max)) {
        if (this.options.digit) {
          this.$digit.text(value);
        }
        return this.circle.animate({
          arc: [this.center, this.center, value, max, this.options.radius]
        }, 200, this.options.animation);
      }
    };

    CircularGraph.prototype.render = function() {
      CircularGraph.__super__.render.apply(this, arguments);
      this.bg = this.paper.circle(this.center, this.center, this.options.radius).attr({
        stroke: this.colors.bg,
        "stroke-width": this.options.lineWidth
      });
      this.circle = this.paper.path().attr({
        stroke: this.colors.highlight,
        "stroke-width": this.options.lineWidth,
        arc: [this.center, this.center, 0, 255, this.options.radius]
      });
      return this;
    };

    return CircularGraph;

  })(Medibot.Views.RaphaelBase);

  Medibot.Views || (Medibot.Views = {});

  Medibot.Views.Compass = (function(_super) {

    __extends(Compass, _super);

    function Compass() {
      return Compass.__super__.constructor.apply(this, arguments);
    }

    Compass.prototype.className = 'compass section';

    Compass.prototype.draw = function() {
      return this.paper;
    };

    Compass.prototype.render = function() {
      Compass.__super__.render.apply(this, arguments);
      this.paper.circle(this.center, this.center, this.options.radius).attr({
        stroke: this.colors.bg,
        'stroke-width': this.options.lineWidth,
        'stroke-dasharray': '--',
        'stroke-linecap': 'butt'
      });
      this.paper.path('M23.383,0C19.415,0,0,70.15,0,70.15l23.383-23.384L46.767,70.15C46.767,70.15,27.352,0,23.383,0z');
      return this;
    };

    return Compass;

  })(Medibot.Views.RaphaelBase);

  Medibot.Views || (Medibot.Views = {});

  Medibot.Views.Hud = (function(_super) {

    __extends(Hud, _super);

    function Hud() {
      return Hud.__super__.constructor.apply(this, arguments);
    }

    Hud.prototype.className = 'hud';

    Hud.prototype.template = Handlebars.templates['hud'];

    Hud.prototype.initialize = function() {
      var _this = this;
      Medibot.socket = io.connect('http://192.168.0.192');
      this.battery = new Medibot.Models.Sensor({
        min: 410,
        max: 565
      });
      this.joystick = new Medibot.Models.Joystick;
      this.motorLeft = new Medibot.Models.Motor;
      this.motorRight = new Medibot.Models.Motor;
      this.sonar = new Medibot.Models.Sonar;
      this.notifications = new Medibot.Collections.Notifications;
      return Medibot.socket.on('read', function(data) {
        _this.battery.set(data.battery);
        _this.sonar.get('ping').set(data.sonar.ping);
        _this.sonar.get('scanner').set(data.sonar.scanner);
        _this.motorLeft.set('value', data.motors.left);
        return _this.motorRight.set('value', data.motors.right);
      });
    };

    Hud.prototype.render = function() {
      this.renderTemplate({});
      this.$toolbar = this.$('.toolbar');
      this.$video = this.$('.video-container');
      this.renderChild(new Medibot.Views.Sensor({
        model: this.battery,
        radius: 20,
        digit: false,
        label: 'Battery'
      }), this.$toolbar);
      this.renderChild(new Medibot.Views.NotificationFooter({
        collection: this.notifications
      }));
      this.renderChild(new Medibot.Views.Sonar({
        model: this.sonar,
        lineWidth: 1,
        radius: 90,
        digit: false,
        label: 'Sonar'
      }), this.$toolbar);
      this.renderChild(new Medibot.Views.BlockGraph({
        model: this.motorLeft,
        height: 20,
        width: 120,
        rows: 1,
        cols: 10,
        lineWidth: 1,
        label: "Motor L",
        direction: 'right'
      }), this.$toolbar);
      this.renderChild(new Medibot.Views.BlockGraph({
        model: this.motorRight,
        height: 20,
        width: 120,
        rows: 1,
        cols: 10,
        lineWidth: 1,
        label: "Motor R",
        direction: 'right'
      }), this.$toolbar);
      this.renderChild(new Medibot.Views.Joystick({
        model: this.joystick,
        $parent: this.$video,
        width: 640,
        height: 320,
        lineWidth: 1,
        digit: false
      }), this.$video);
      return this;
    };

    return Hud;

  })(Medibot.Views.Base);

  Medibot.Views || (Medibot.Views = {});

  Medibot.fn = {};

  Medibot.fn.constrain = function(x, lower, upper) {
    if (x <= upper && x >= lower) {
      return x;
    } else {
      if (x > upper) {
        return upper;
      } else {
        return lower;
      }
    }
  };

  Medibot.Views.Joystick = (function(_super) {

    __extends(Joystick, _super);

    function Joystick() {
      this.end = __bind(this.end, this);

      this.move = __bind(this.move, this);

      this.added = __bind(this.added, this);

      this.start = __bind(this.start, this);
      return Joystick.__super__.constructor.apply(this, arguments);
    }

    Joystick.prototype.className = 'joystick';

    Joystick.prototype.events = {
      'click .button': 'sourceChange'
    };

    Joystick.prototype.initialize = function(options) {
      var _this = this;
      this.options = options != null ? options : {};
      _.defaults(this.options, {
        animation: "<>",
        lineWidth: 8,
        digit: true,
        frequency: 100
      });
      this.$parent = this.options.$parent;
      return $(window).on('resize', function() {
        return _this.resize(_this.$parent.width(), _this.$parent.height());
      });
    };

    Joystick.prototype.start = function() {
      return this.control.animate({
        fill: this.colors.highlight2
      }, 300, '<>');
    };

    Joystick.prototype.added = function() {
      var $video;
      $video = $('.video');
      return this.resize($video.width(), $video.height());
    };

    Joystick.prototype.move = function(dx, dy) {
      var hHeight, hWidth, pos;
      hWidth = this.options.width / 2;
      hHeight = this.options.height / 2;
      dx = Medibot.fn.constrain(dx, -hWidth, hWidth);
      dy = Medibot.fn.constrain(dy, -hHeight, hHeight);
      pos = {
        x: dx / hWidth,
        y: dy / hHeight
      };
      this.model.set({
        pos: pos
      });
      return this.control.attr({
        cx: this.cx + dx,
        cy: this.cy + dy
      });
    };

    Joystick.prototype.end = function() {
      return this.control.animate({
        cx: this.cx,
        cy: this.cy,
        fill: this.colors.highlight
      }, 200, 'backOut');
    };

    Joystick.prototype.sourceChange = function(evt) {
      return this.model.set({
        sourceOn: $('.buttons li').index($(evt.target).parent())
      });
    };

    Joystick.prototype.render = function() {
      var sources;
      Joystick.__super__.render.apply(this, arguments);
      $('.joystick').livequery(this.added);
      sources = this.model.get('sources');
      this.$el.append("<ul class='buttons'><li><a href='#' class='button " + sources[0] + "-button'>                 " + sources[0] + "</a></li><li><a href='#' class='button " + sources[1] + "-button'>" + sources[1] + "</a></li></ul>");
      this.bg = this.paper.rect(0, 0, this.options.width, this.options.height).attr({
        stroke: this.colors.bg,
        'stroke-width': this.lineWidth
      });
      this.home = this.paper.circle(this.cx, this.cy, 30).attr({
        fill: this.colors.bg,
        stroke: false
      });
      this.control = this.paper.circle(this.cx, this.cy, 30).attr({
        stroke: false,
        fill: this.colors.highlight,
        opacity: 0.7,
        "stroke-width": this.options.lineWidth
      });
      this.control.drag(this.move, this.start, this.end);
      return this;
    };

    return Joystick;

  })(Medibot.Views.RaphaelBase);

  Medibot.Views || (Medibot.Views = {});

  Medibot.Views.NotificationFooter = (function(_super) {

    __extends(NotificationFooter, _super);

    function NotificationFooter() {
      return NotificationFooter.__super__.constructor.apply(this, arguments);
    }

    NotificationFooter.prototype.tagName = 'div';

    NotificationFooter.prototype.template = Handlebars.templates['notification'];

    NotificationFooter.prototype.className = 'notification media';

    NotificationFooter.prototype.animation = 'fadeInUp fast';

    NotificationFooter.prototype.initialize = function(options) {
      if (options == null) {
        options = {};
      }
      _.bindAll(this, 'render');
      return this.collection.bind('add', this.render);
    };

    NotificationFooter.prototype.render = function() {
      var model;
      if (this.collection.length > 0) {
        model = this.collection.first();
        if (model.get('priority') > 0) {
          this.renderTemplate(model.toJSON());
          this.showFor(5);
        }
      }
      return this;
    };

    return NotificationFooter;

  })(Medibot.Views.Base);

  Medibot.Views || (Medibot.Views = {});

  Medibot.Views.Sensor = (function(_super) {

    __extends(Sensor, _super);

    function Sensor() {
      return Sensor.__super__.constructor.apply(this, arguments);
    }

    Sensor.prototype.className = 'circular-graph section';

    Sensor.prototype.tagName = 'div';

    return Sensor;

  })(Medibot.Views.CircularGraph);

  Medibot.Views || (Medibot.Views = {});

  Medibot.Views.Sonar = (function(_super) {

    __extends(Sonar, _super);

    function Sonar() {
      return Sonar.__super__.constructor.apply(this, arguments);
    }

    Sonar.prototype.className = 'sonar-graph section';

    Sonar.prototype.draw = function() {
      var ping, point, scanner;
      scanner = this.model.get('scanner');
      ping = this.model.get('ping');
      if (ping.get('distance') < ping.get('max')) {
        point = this.paper.rect((ping.get('distance') / ping.get('max')) * this.options.radius, this.center - this.options.lineWidth, 5, 5).rotate(scanner.get('degrees'), this.center, this.center - this.options.lineWidth).attr({
          fill: this.colors.highlight,
          stroke: false
        });
        point.animate({
          opacity: 0
        }, 5000, this.options.animation, function() {
          return point.remove();
        });
      }
      this.core.animate({
        'stroke-width': 50,
        'stroke-opacity': 0
      }, 500, this.options.animation, function() {
        return this.attr({
          'stroke-opacity': 1,
          'stroke-width': 0
        });
      });
      return this.beam.animate({
        transform: "R" + (scanner.get('degrees')) + "," + this.center + "," + (this.center - this.options.lineWidth)
      }, 1000);
    };

    Sonar.prototype.render = function() {
      var range, scanner, sector, steps, _i, _len, _ref;
      Sonar.__super__.render.apply(this, arguments);
      this.paper.setSize(this.center * 2, this.center);
      scanner = this.model.get('scanner');
      range = scanner.get('range');
      steps = scanner.get('steps');
      this.beam = this.paper.sector(this.center, this.center - this.options.lineWidth, this.options.radius, range[1] - steps, range[1]).attr({
        fill: this.colors.transparent,
        stroke: false
      });
      this.core = this.paper.sector(this.center, this.center - this.options.lineWidth, 5, range[0], range[1]).attr({
        fill: this.colors.highlight,
        stroke: this.colors.highlight,
        'stroke-width': 0,
        'stroke-opacity': 0.2
      });
      _ref = _.range(this.options.radius, 10, -10);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        sector = _ref[_i];
        this.paper.sector(this.center, this.center - this.options.lineWidth, sector, range[0], range[1]).attr({
          stroke: this.colors.bg,
          'stroke-width': 1,
          'stroke-opacity': 1
        });
      }
      return this;
    };

    return Sonar;

  })(Medibot.Views.RaphaelBase);

  $.fn.animationComplete = function(callback) {
    var animationEnd;
    if (Modernizr.cssanimations) {
      animationEnd = "animationend webkitAnimationEnd";
      if ($.isFunction(callback)) {
        return $(this).one(animationEnd, callback);
      }
    } else {
      setTimeout(callback, 0);
      return $(this);
    }
  };

  $.fn.animateCSS = function(animation, callback) {
    animation || (animation = "none");
    $(this).addClass("animated " + animation).animationComplete(function() {
      $(this).removeClass("animated " + animation);
      if (callback) {
        return callback();
      }
    });
    return $(this);
  };

  window.requestAnimFrame = (function() {
    return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
      return window.setTimeout(callback, 1000 / 60);
    };
  })();

  $('body').on("touchmove", function(evt) {
    return evt.preventDefault();
  });

  Raphael.fn.sector = function(cx, cy, r, startAngle, endAngle) {
    var rad, x1, x2, y1, y2;
    rad = Math.PI / 180;
    x1 = cx + r * Math.cos(-startAngle * rad);
    x2 = cx + r * Math.cos(-endAngle * rad);
    y1 = cy + r * Math.sin(-startAngle * rad);
    y2 = cy + r * Math.sin(-endAngle * rad);
    return this.path(["M", cx, cy, "L", x1, y1, "A", r, r, 0, +(endAngle - startAngle > 180), 0, x2, y2, "z"]);
  };

  Raphael.fn.roundedRectangle = function(x, y, w, h, r1, r2, r3, r4) {
    var array;
    array = [];
    array = array.concat(["M", x, r1 + y, "Q", x, y, x + r1, y]);
    array = array.concat(["L", x + w - r2, y, "Q", x + w, y, x + w, y + r2]);
    array = array.concat(["L", x + w, y + h - r3, "Q", x + w, y + h, x + w - r3, y + h]);
    array = array.concat(["L", x + r4, y + h, "Q", x, y + h, x, y + h - r4, "Z"]);
    return this.path(array);
  };

}).call(this);
