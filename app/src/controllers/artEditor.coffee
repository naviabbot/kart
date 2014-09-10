_ = require 'underscore'
Spine._ = require 'underscore'
$      = Spine.$

shell = require('shell');
Spinner = require('spin.js')

class ArtEditor extends Spine.Controller
  className: 'app-artEditor'

  elements:
    '.art-editor-modal': 'artEditorModal'
    '.status-title': 'statusTitle'
    '.cards': 'cards'

  constructor: ->
    super

    @art = []

    @spinner = new Spinner({
      lines: 10,
      length: 9,
      width: 6,
      radius: 13,
      corners: 1,
      rotate: 0,
      direction: 1,
      color: '#fff',
      speed: 1.4,
      trail: 60,
      shadow: false,
      hwaccel: true,
      className: 'spinner',
      zIndex: 2e9
    })

    @render()

  render: ->
    @html @view 'main/artEditor', @

  cardFor: (url) ->
    data = {"imagePath": url, "title": ""}
    @view 'main/_card', data

  show: (game) ->
    self = @

    $('.footer a').click (e) ->
      e.preventDefault()
      shell.openExternal(e.target.href);

    @artEditorModal.modal({
      overlayClose:true,
      minHeight: '60%',
      maxHeight: '60%',
      minWidth: '60%',
      maxWidth: '60%',
      onShow: (modal) ->
        self.statusTitle.html("Searching for: #{game.name()}")
        self.spinner.spin()
        self.artEditorModal.append(self.spinner.el)

        $.get "http://console-grid-api.herokuapp.com/search?q=#{encodeURI(game.name())}", (data) ->
          self.spinner.stop()
          self.statusTitle.html("Found: #{data.name}")
          self.art = data.art

          for art in self.art
            el = self.cardFor(art.url)
            self.cards.append(el)

          $(modal.container).find('.card').click (e) ->
            card = $(e.currentTarget)
            art = self.art[card.index()]
            game.setImage art.url, () ->
              $.modal.close()

      onClose: (modal) ->
        self.cards.html("")
        $.modal.close()
    })

module.exports = ArtEditor