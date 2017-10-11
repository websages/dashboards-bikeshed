class Dashing.Bcycle extends Dashing.Widget

    @accessor 'backgroundClass', ->
        if @get('status') == "Active"
            "bcycle-status-active"
        else if @get('status') == "Unavailable"
            "bcycle-status-unavailable"
        else
            "bcycle-status-unknown"

    constructor: ->
        super

    ready: ->
        $(@node).addClass(@get('backgroundClass'))

    onData: (data) ->
        console.log 'sent data', data
        $(@node).addClass(@get('backgroundClass'))
