window.ASAP = (->
    fns = []
    callall = () ->
        f() while f = fns.shift()
    if document.addEventListener
        document.addEventListener 'DOMContentLoaded', callall, false
        window.addEventListener 'load', callall, false
    else if document.attachEvent
        document.attachEvent 'onreadystatechange', callall
        window.attachEvent 'onload', callall
    (fn) ->
        fns.push fn
        callall() if document.readyState is 'complete'
)()

log = () ->
    if window.console and window.DEBUG
        console.group? window.DEBUG
        if arguments.length == 1 and Array.isArray(arguments[0]) and console.table
            console.table.apply window, arguments
        else
            console.log.apply window, arguments
        console.groupEnd?()
trouble = () ->
    if window.console
        console.group? window.DEBUG if window.DEBUG
        console.warn?.apply window, arguments
        console.groupEnd?() if window.DEBUG

window.preload = (what, fn) ->
    what = [what] unless  Array.isArray(what)
    $.when.apply($, ($.ajax(lib, dataType: 'script', cache: true) for lib in what)).done -> fn?()

window.queryParam = queryParam = (p, nocase) ->
    params_kv = location.search.substr(1).split('&')
    params = {}
    params_kv.forEach (kv) -> k_v = kv.split('='); params[k_v[0]] = k_v[1] or ''
    if p
        if nocase
            return decodeURIComponent(params[k]) for k of params when k.toUpperCase() == p.toUpperCase()
            return undefined
        else
            return decodeURIComponent params[p]
    params

String::zeroPad = (len, c) ->
    s = ''
    c ||= '0'
    len ||= 2
    len -= @length
    s += c while s.length < len
    s + @
Number::zeroPad = (len, c) -> String(@).zeroPad len, c

Number::pluralForm = (root, suffix_list) ->
    root + (if this >= 11 && this <= 14 then suffix_list[0] else suffix_list[this % 10]);
Number::asDays = () ->
    d = Math.floor(this)
    d.pluralForm('д', ['ней', 'ень', 'ня', 'ня', 'ня', 'ней', 'ней', 'ней', 'ней', 'ней']).toLowerCase()
Number::asHours = () ->
    d = Math.floor(this)
    d.pluralForm('час', ['ов', '', 'а', 'а', 'а', 'ов', 'ов', 'ов', 'ов', 'ов']).toLowerCase()
Number::asMinutes = () ->
    d = Math.floor(this)
    d.pluralForm('минут', ['', 'а', 'ы', 'ы', 'ы', '', '', '', '', '']).toLowerCase()
Number::asSeconds = () ->
    d = Math.floor(this)
    d.pluralForm('секунд', ['', 'а', 'ы', 'ы', 'ы', '', '', '', '', '']).toLowerCase()


window.DEBUG = 'APP NAME'

ASAP ->
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


ASAP ->

    $('.countdown-widget').Flipdown()

    window.flipme2 = (stack_el, n) ->
        $stack_el = $(stack_el)
        $recent_flipper = $stack_el.children().eq(0)
        $new_flipper = $ "<div class='flipper flip-in' data-digit='#{ n }'></div>"
        $stack_el.append $new_flipper
        $recent_flipper.one 'transitionend', (e) ->
            $new_flipper.one 'transitionend', ->
                $recent_flipper.remove()
            .removeClass 'flip-in'
        .addClass 'flip-out'