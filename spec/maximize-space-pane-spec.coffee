

describe 'Maximize Space Pane', ->
  beforeEach ->
    @commands =
      _target: atom.views.getView atom.workspace
      switch: (number) ->
        atom.commands.dispatch @_target,
                               "Maximize Space Pane: Switch #{number}"
      reset: ->
        atom.commands.dispatch @_target, 'Maximize Space Pane: Reset'

    @panes = {}
    @panes.pane1 = atom.workspace.getActivePane()
    @panes.pane2 = @panes.pane1.splitRight()

    atom.workspace.open()

  it 'Switchable by switch', (done) ->
    @commands.switch 1
    setTimeout =>
      paneModel = atom.workspace.getActivePane()
      paneElement = atom.views.getView paneModel
      expect(paneModel).toBe(@panes.pane1)
      expect(paneElement.classList.contains '.atom-maximum-space-pane--maximum-glow').toBe(true)
      done()
    , 0

    @commands.switch 2
    setTimeout =>
      expect(atom.workspace.getActivePane()).toBe(@panes.pane2)
    , 0

  it 'After switching with the switch, reset', (done) ->
    @commands.switch 1
    setTimeout =>
      paneModel = atom.workspace.getActivePane()
      paneElement = atom.views.getView paneModel
      expect(paneModel).toBe(@panes.pane1)
      expect(paneElement.classList.contains '.atom-maximum-space-pane--maximum-glow').toBe(true)
      done()
    , 0

    @commands.reset()
    setTimeout =>
      paneElement = atom.views.getView paneModel
      expect(paneElement.classList.contains '.atom-maximum-space-pane--maximum-glow').toBe(false)
    , 0
