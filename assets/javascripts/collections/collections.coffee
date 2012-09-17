Medibot.Collections ||= {}

Medibot.Collections.Notifications = Backbone.Collection.extend
  model: Medibot.Models.Notification

Medibot.Collections.Sensors = Backbone.Collection.extend
	model: Medibot.Models.Sensor