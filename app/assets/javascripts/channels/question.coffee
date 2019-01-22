App.question = App.cable.subscriptions.create { channel: "QuestionChannel", question_id: gon.question_id },
  connected: ->
    # comments mighty comments

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->

    if data['answer']
      $('.all-answers .answers-list').append(JST["templates/answer"]({ data: data }))
    else if data['comment']
      if data['comment'].commentable_type == "Question"
        console.log('Hello! Can you herr me?')
        $('.question-comments .comments-list').append(JST["templates/comments"]({ data: data }))
      else if data['comment'].commentable_type == "Answer"
        $(".answers .all-answers .answer-instance#answer-info-#{data['commentable_id']} .answer-comments .comments-list").append(JST["templates/comments"]({ data: data}))
