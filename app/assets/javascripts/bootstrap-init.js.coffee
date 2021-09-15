Bootstrap =
  elems:
    datefield: ->
      return $('[data-behaviour~=datepicker]')
    wysiwyg: ->
      return $('[data-behaviour~=wysiwyg]')
    chosen: ->
      return $('[data-behaviour~=chosen]')
    tabable: ->
      return $('[data-behaviour~=tabable]')
    popover_tooltip: ->
      return $('[data-toggle~=popover]')
    tooltip: ->
      return $('[data-toggle~=tooltip]')

  init : ->
    _that = this

    this.elems.chosen().chosen({
      allow_single_deselect: false
      no_results_text: 'No results matched'
    })

    this.elems.tabable().find('a').click (e) ->
      e.preventDefault()
      $(this).tab('show')

    this.elems.popover_tooltip().popover()
    this.elems.tooltip().tooltip()

$(document).ready ->
  Bootstrap.init()
  $('.acts_as_list').sortable
    axis: 'y'
    update: ->
      $.post($(this).data('url'), $(this).sortable('serialize'))

  $('#sortitem').sortable
    axis: 'y'
    update: ->
      #alert($(this).data('target'))
      $.post($(this).data('update-url'), $(this).sortable('serialize'), (success) -> alert(html))

$(document).on "fileselect", '.btn-file :file', (event, numFiles, label) ->
  input = $(this).parents(".input-group").find(":text")
  log = (if numFiles > 1 then numFiles + " files selected" else label)
  input.val log

$(document).on "ajax:complete", "[data-target]", (e, data, status, xhr) ->
  target = $(this).attr("data-target")
  $(target).html(data.responseText)

$(document).on "change", ".btn-file :file", () ->
  input = $(this)
  numFiles = (if input.get(0).files then input.get(0).files.length else 1)
  label = input.val().replace(/\\/g, "/").replace(/.*\//, "")
  input.trigger "fileselect", [
    numFiles
    label
  ]
  return
