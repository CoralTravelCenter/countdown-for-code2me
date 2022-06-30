var log, queryParam, trouble,
  slice = [].slice;

window.ASAP = (function() {
  var callall, fns;
  fns = [];
  callall = function() {
    var f, results;
    results = [];
    while (f = fns.shift()) {
      results.push(f());
    }
    return results;
  };
  if (document.addEventListener) {
    document.addEventListener('DOMContentLoaded', callall, false);
    window.addEventListener('load', callall, false);
  } else if (document.attachEvent) {
    document.attachEvent('onreadystatechange', callall);
    window.attachEvent('onload', callall);
  }
  return function(fn) {
    fns.push(fn);
    if (document.readyState === 'complete') {
      return callall();
    }
  };
})();

log = function() {
  if (window.console && window.DEBUG) {
    if (typeof console.group === "function") {
      console.group(window.DEBUG);
    }
    if (arguments.length === 1 && Array.isArray(arguments[0]) && console.table) {
      console.table.apply(window, arguments);
    } else {
      console.log.apply(window, arguments);
    }
    return typeof console.groupEnd === "function" ? console.groupEnd() : void 0;
  }
};

trouble = function() {
  var ref;
  if (window.console) {
    if (window.DEBUG) {
      if (typeof console.group === "function") {
        console.group(window.DEBUG);
      }
    }
    if ((ref = console.warn) != null) {
      ref.apply(window, arguments);
    }
    if (window.DEBUG) {
      return typeof console.groupEnd === "function" ? console.groupEnd() : void 0;
    }
  }
};

window.preload = function(what, fn) {
  var lib;
  if (!Array.isArray(what)) {
    what = [what];
  }
  return $.when.apply($, (function() {
    var i, len1, results;
    results = [];
    for (i = 0, len1 = what.length; i < len1; i++) {
      lib = what[i];
      results.push($.ajax(lib, {
        dataType: 'script',
        cache: true
      }));
    }
    return results;
  })()).done(function() {
    return typeof fn === "function" ? fn() : void 0;
  });
};

window.queryParam = queryParam = function(p, nocase) {
  var k, params, params_kv;
  params_kv = location.search.substr(1).split('&');
  params = {};
  params_kv.forEach(function(kv) {
    var k_v;
    k_v = kv.split('=');
    return params[k_v[0]] = k_v[1] || '';
  });
  if (p) {
    if (nocase) {
      for (k in params) {
        if (k.toUpperCase() === p.toUpperCase()) {
          return decodeURIComponent(params[k]);
        }
      }
      return void 0;
    } else {
      return decodeURIComponent(params[p]);
    }
  }
  return params;
};

String.prototype.zeroPad = function(len, c) {
  var s;
  s = '';
  c || (c = '0');
  len || (len = 2);
  len -= this.length;
  while (s.length < len) {
    s += c;
  }
  return s + this;
};

Number.prototype.zeroPad = function(len, c) {
  return String(this).zeroPad(len, c);
};

Number.prototype.pluralForm = function(root, suffix_list) {
  return root + (this >= 11 && this <= 14 ? suffix_list[0] : suffix_list[this % 10]);
};

Number.prototype.asDays = function() {
  var d;
  d = Math.floor(this);
  return d.pluralForm('д', ['ней', 'ень', 'ня', 'ня', 'ня', 'ней', 'ней', 'ней', 'ней', 'ней']).toLowerCase();
};

Number.prototype.asHours = function() {
  var d;
  d = Math.floor(this);
  return d.pluralForm('час', ['ов', '', 'а', 'а', 'а', 'ов', 'ов', 'ов', 'ов', 'ов']).toLowerCase();
};

Number.prototype.asMinutes = function() {
  var d;
  d = Math.floor(this);
  return d.pluralForm('минут', ['', 'а', 'ы', 'ы', 'ы', '', '', '', '', '']).toLowerCase();
};

Number.prototype.asSeconds = function() {
  var d;
  d = Math.floor(this);
  return d.pluralForm('секунд', ['', 'а', 'ы', 'ы', 'ы', '', '', '', '', '']).toLowerCase();
};

window.DEBUG = 'APP NAME';

ASAP(function() {
  return (function($, window) {
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
});

ASAP(function() {
  $('.countdown-widget').Flipdown();
  return window.flipme2 = function(stack_el, n) {
    var $new_flipper, $recent_flipper, $stack_el;
    $stack_el = $(stack_el);
    $recent_flipper = $stack_el.children().eq(0);
    $new_flipper = $("<div class='flipper flip-in' data-digit='" + n + "'></div>");
    $stack_el.append($new_flipper);
    return $recent_flipper.one('transitionend', function(e) {
      return $new_flipper.one('transitionend', function() {
        return $recent_flipper.remove();
      }).removeClass('flip-in');
    }).addClass('flip-out');
  };
});
