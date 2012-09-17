Medibot.Views ||= {}

class Medibot.Views.NotificationFooter extends Medibot.Views.Base
  tagName: 'div'
  template: Handlebars.templates['notification']
  className: 'notification media'
  animation: 'fadeInUp fast'

  initialize: (options = {}) ->
    _.bindAll @, 'render'
    @collection.bind 'add', @render

  render: ->
    if @collection.length > 0
      model = @collection.first()
      if model.get('priority') > 0
        @renderTemplate model.toJSON()
        @showFor 5
    @