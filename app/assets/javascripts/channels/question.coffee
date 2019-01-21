App.question = App.cable.subscriptions.create { channel: "QuestionChannel", question_id: gon.question_id },
  connected: ->
    # comments mighty comments

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    $('.all-answers .answers-list').append(JST["templates/answer"]({ data: data }))