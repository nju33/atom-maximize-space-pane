{CompositeDisposable} = require 'atom'
StatusBar = require './status-bar'

RESET_FLEX_DIRECTION = 'atom-maximize-space-pane--reset-flex-direction'
MAXIMUM_GROW = 'atom-maximum-space-pane--maximum-glow'

module.exports =
  activate: (state) ->
    @subscription = new CompositeDisposable()

    @subscription.add atom.commands.add 'atom-workspace',
      'Maximize Space Pane: Switch 1': => @switch 1
    @subscription.add atom.commands.add 'atom-workspace',
      'Maximize Space Pane: Switch 2': => @switch 2
    @subscription.add atom.commands.add 'atom-workspace',
      'Maximize Space Pane: Switch 3': => @switch 3
    @subscription.add atom.commands.add 'atom-workspace',
      'Maximize Space Pane: Switch 4': => @switch 4
    @subscription.add atom.commands.add 'atom-workspace',
      'Maximize Space Pane: Switch 5': => @switch 5
    @subscription.add atom.commands.add 'atom-workspace',
      'Maximize Space Pane: Switch 6': => @switch 6
    @subscription.add atom.commands.add 'atom-workspace',
      'Maximize Space Pane: Switch 7': => @switch 7
    @subscription.add atom.commands.add 'atom-workspace',
      'Maximize Space Pane: Switch 8': => @switch 8
    @subscription.add atom.commands.add 'atom-workspace',
      'Maximize Space Pane: Switch 9': => @switch 9
    @subscription.add atom.commands.add 'atom-workspace',
      'Maximize Space Pane: Reset': =>
        @reset() if @activePane?

    setTimeout =>
      @statusBar = new StatusBar()
      @statusBar.build @getPanes()
    , 0

    @subscription.add atom.workspace.onDidAddPane ({pane}) =>
      setTimeout =>
        @activeNumber = -1
        unless pane? and @activePane? and @statusBar.activeRadio?
          @statusBar.build @getPanes()
          return

        pane = @getPaneElement pane
        idx = @paneIndexOf pane

        if ~idx
          @switch idx + 1
        else
          @reset()

        @statusBar.build @getPanes()
      , 0

    @subscription.add atom.workspace.onDidDestroyPane =>
      @activeNumber = -1

    @subscription.add atom.workspace.onDidChangeActivePane (pane) =>
      setTimeout =>
        unless pane? and @activePane? and @statusBar.activeRadio?
          @statusBar.build @getPanes()
          return

        @reset() if @isOnlyPane()

        pane = @getPaneElement pane
        idx = @paneIndexOf pane

        if ~idx
          @switch idx + 1
        else
          @reset()

        @statusBar.build @getPanes()
      , 0

    @activePane = null
    @activePaneLength = null
    @activeNumber = null

  deactivate: ->
    @subscription.dispose()

  isOnlyPane: ->
    {panes} = @getPanes()
    panes.length is 1

  paneIndexOf: (pane) ->
    {panes} = @getPanes()
    found = false

    for _pane, idx in panes
      if _pane is pane
        found = true
        break

    if found then idx else -1

  getPaneElement: (item) ->
    switch item.constructor.name
      when 'Pane'
        item.activeItem?.editorElement.parentElement.parentElement
      when 'TextEditor'
        item.editorElement.parentElement.parentElement

  switch: (number) ->
    return if number is @activeNumber

    {parent, panes} = @getPanes()
    return unless number <= panes.length

    @reset() if @activePane?

    if (!parent.classList.contains RESET_FLEX_DIRECTION)
      parent.classList.add RESET_FLEX_DIRECTION

    @activeNumber = number
    pane = @activePane = panes[@activeNumber - 1]
    if (!pane.classList.contains MAXIMUM_GROW)
      pane.classList.add MAXIMUM_GROW
      # for repaint
      @activePane.style.opacity = '0'
      @activePane.style.opacity = '1'

    if @statusBar.activeRadio?
      @statusBar.deactivateRadio @statusBar.activeRadio
    @statusBar.activateRadio number - 1

  reset: ->
    radio = @statusBar.activeRadio
    return unless radio?

    {parent} = @getPanes()

    if (parent.classList.contains RESET_FLEX_DIRECTION)
      parent.classList.remove RESET_FLEX_DIRECTION
    if (@activePane.classList.contains MAXIMUM_GROW)
      @activePane.classList.remove MAXIMUM_GROW
      # for repaint
      @activePane.style.opacity = '0'
      @activePane.style.opacity = '1'

    @activePane = null
    @activeNumber = null
    @statusBar.deactivateRadio radio

  getPanes: do ->
    workspace = atom.views.getView atom.workspace
    filter = (arr) ->
      arr.filter (el) ->
        /atom-pane(?!-)|atom-pane-axis/i.test el.tagName
    ->
      parent = workspace.querySelector('.panes').children[0]
      return {parent, panes: [parent]} if parent.tagName is 'ATOM-PANE'

      initialArr = filter [].slice.call parent.children
      panes = initialArr.reduce (result, el) ->
        if el.classList.contains 'pane-row'
          result.conact filter [].slice.call el.children
        else
          result.push el
        result
      , []

      {parent, panes}
