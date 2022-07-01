window.ASAP ||= (->
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

window.log ||= () ->
    if window.console and window.DEBUG
        console.group? window.DEBUG
        if arguments.length == 1 and Array.isArray(arguments[0]) and console.table
            console.table.apply window, arguments
        else
            console.log.apply window, arguments
        console.groupEnd?()
window.trouble ||= () ->
    if window.console
        console.group? window.DEBUG if window.DEBUG
        console.warn?.apply window, arguments
        console.groupEnd?() if window.DEBUG

window.preload ||= (what, fn) ->
    what = [what] unless  Array.isArray(what)
    $.when.apply($, ($.ajax(lib, dataType: 'script', cache: true) for lib in what)).done -> fn?()

window.queryParam ||= queryParam = (p, nocase) ->
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
    d.pluralForm('д', ['ней', 'ень', 'ня', 'ня', 'ня', 'ней', 'ней', 'ней', 'ней', 'ней'])
Number::asHours = () ->
    d = Math.floor(this)
    d.pluralForm('час', ['ов', '', 'а', 'а', 'а', 'ов', 'ов', 'ов', 'ов', 'ов'])
Number::asMinutes = () ->
    d = Math.floor(this)
    d.pluralForm('минут', ['', 'а', 'ы', 'ы', 'ы', '', '', '', '', ''])
Number::asSeconds = () ->
    d = Math.floor(this)
    d.pluralForm('секунд', ['', 'а', 'ы', 'ы', 'ы', '', '', '', '', ''])


ASAP ->
    do($ = window.jQuery, window) ->
        class Flipdown
            defaults:
                momentX: moment().add({ d: 2 })
                labels: yes

            constructor: (el, options) ->
                @options = $.extend({}, @defaults, options)
                @$el = $(el)
                @init()

            init: () -> @

            tick: () ->
                remains = moment.duration(@options.momentX.diff(moment()))
                if remains.seconds() < 0
                    @over()
                    return @
                @render remains
                @rafh = requestAnimationFrame =>
                    @tick()
                @

            start: () -> @tick()

            stop: () ->
                cancelAnimationFrame @rafh if @rafh
                @

            over: () ->
                @stop()
                @$el.trigger('time-is-up')
                @

            render: (remains) ->
                hit_non_zero_rank = false
                @$el.find('[data-units]').each (idx, el) =>
                    $units = $(el)
                    units = $units.attr('data-units')
                    value = Number($units.attr('data-value'))
                    value2set = remains[units]()
                    hit_non_zero_rank ||= value2set != 0
                    $units.addClass 'insignificant' unless hit_non_zero_rank
                    if value2set != value
                        $units.attr 'data-value', value2set
                        digits2set = value2set.zeroPad(2)
                        $stacks = $units.find('.flipper-stack')
                        @flipStack2 $stacks.eq(0), digits2set[0]
                        @flipStack2 $stacks.eq(1), digits2set[1]
                        $units.find('.label').text value2set[{
                            days: 'asDays',
                            hours: 'asHours',
                            minutes: 'asMinutes',
                            seconds: 'asSeconds'
                        }[units]]() if @options.labels
                @

            flipStack2: (stack_el, n) ->
                $stack_el = $(stack_el)
                if $stack_el.find('.flipper:first').attr('data-digit') != String(n)
                    $recent_flipper = $stack_el.children().eq(0)
                    $new_flipper = $ "<div class='flipper flip-in' data-digit='#{ n }'></div>"
                    $stack_el.append $new_flipper
                    $recent_flipper.one 'transitionend', (e) ->
                        $new_flipper.one 'transitionend', ->
                            $recent_flipper.remove()
                        .removeClass 'flip-in'
                    .addClass 'flip-out'


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
    window.$countdown = $('.countdown-widget').Flipdown()
    $countdown.on 'time-is-up', ->
        alert 'OVER'
    .Flipdown('start')

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
