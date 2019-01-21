App.questions = App.cable.subscriptions.create "QuestionsChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    $('.all-questions').append(JST["templates/question"]({ data: data }))
