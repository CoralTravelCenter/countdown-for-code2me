do($ = window.jQuery, window) ->
    class Flipdown
        defaults:
            momentX: moment().add({ d: 2 })

        constructor: (el, options) ->
            @options = $.extend({}, @defaults, options)
            @$el = $(el)
            @init()

        init: () ->
            @

        tick: () ->
            remains = moment.duration(@options.momentX.diff(moment()))
            if remains.seconds <= 0
                @over()
                return @
            @render remains

        start: () ->
            @rafh = requestAnimationFrame =>
                @tick()
            @

        stop: () ->
            cancelAnimationFrame @rafh if @rafh
            @

        over: () ->
            @stop()
            @$el.trigger('time-is-up')
            @

        render: (remains) ->
            @

        # Define the plugin
        $.fn.extend Flipdown: (option, args...) ->
            @each ->
                $this = $(this)
                data = $this.data('Flipdown')
                if !data
                    $this.data 'Flipdown', (data = new Flipdown(this, option))
                if typeof option == 'string'
                    data[option].apply(data, args)
