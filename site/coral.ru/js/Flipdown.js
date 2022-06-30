var slice = [].slice;

(function($, window) {
  var Flipdown;
  return Flipdown = (function() {
    Flipdown.prototype.defaults = {
      momentX: moment().add({
        d: 2
      })
    };

    function Flipdown(el, options) {
      this.options = $.extend({}, this.defaults, options);
      this.$el = $(el);
      this.init();
    }

    Flipdown.prototype.init = function() {
      return this;
    };

    Flipdown.prototype.tick = function() {
      var remains;
      remains = moment.duration(this.options.momentX.diff(moment()));
      if (remains.seconds <= 0) {
        this.over();
        return this;
      }
      return this.render(remains);
    };

    Flipdown.prototype.start = function() {
      this.rafh = requestAnimationFrame((function(_this) {
        return function() {
          return _this.tick();
        };
      })(this));
      return this;
    };

    Flipdown.prototype.stop = function() {
      if (this.rafh) {
        cancelAnimationFrame(this.rafh);
      }
      return this;
    };

    Flipdown.prototype.over = function() {
      this.stop();
      this.$el.trigger('time-is-up');
      return this;
    };

    Flipdown.prototype.render = function(remains) {
      return this;
    };

    $.fn.extend({
      Flipdown: function() {
        var args, option;
        option = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        return this.each(function() {
          var $this, data;
          $this = $(this);
          data = $this.data('Flipdown');
          if (!data) {
            $this.data('Flipdown', (data = new Flipdown(this, option)));
          }
          if (typeof option === 'string') {
            return data[option].apply(data, args);
          }
        });
      }
    });

    return Flipdown;

  })();
})(window.jQuery, window);
