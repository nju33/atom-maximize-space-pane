module.exports = class StatusBar
  constructor: (panes) ->
    @activeRadio = null
    @root = null
    @children = []

    @appendStatusBar @createRoot()

  hasNextPane: (idx) ->
    @children[idx + 1]?

  appendStatusBar: (el) ->
    workspace = atom.views.getView atom.workspace
    statusBar = workspace.querySelector '.status-bar > .flexbox-repaint-hack'
    statusBar.insertBefore el, statusBar.children[1]

  createRoot: ->
    statusBarCenter = document.createElement 'div'
    statusBarCenter.className = 'atom-maximize-space-pane__status-box__status-bar-center'
    @root = document.createElement 'div'
    @root.className = 'atom-maximize-space-pane__box'
    @root.style.opacity = '.4'
    statusBarCenter.appendChild @root
    statusBarCenter

  createChild: ->
    child = document.createElement 'div'
    child.className = 'atom-maximize-space-pane__radio'
    child

  build: ({panes}) ->
    return if panes.length is 0

    if panes.length is 1
      @root.style.display = 'none'
    else
      @root.style.display = ''

    diff = panes.length - @children.length
    if diff > 0
      for i in [1..diff]
        child = @createChild()
        @children.push child
        @append child
    else if diff < 0
      for i in [-1..diff]
        child = @children.pop()
        child.parentElement.removeChild child

  append: (child) ->
    @root.appendChild child

  activateRadio: (idx) ->
    @activeRadio = @children[idx]
    @activeRadio.classList.add 'atom-maximize-space-pane__radio--active'

    @root.style.opacity = ''
    @setTitle "Maximum Pane #{idx + 1}"

  deactivateRadio: (radio) ->
    if radio.classList.contains 'atom-maximize-space-pane__radio--active'
      radio.classList.remove 'atom-maximize-space-pane__radio--active'
      @activeRadio = null

    setTimeout =>
      unless @activeRadio?
        @root.style.opacity = '.4'
        @removeTitle()
    , 0

  setTitle: (text) ->
    @root.setAttribute 'title', text

  removeTitle: ->
    @root.removeAttribute 'title'
