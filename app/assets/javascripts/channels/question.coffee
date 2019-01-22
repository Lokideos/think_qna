App.question = App.cable.subscriptions.create { channel: "QuestionChannel", question_id: gon.question_id },
  connected: ->
    # comments mighty comments

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    if data['data']['answer'] && gon.current_user_id != data['data']['answer'].user_id
      $('.all-answers .answers-list').append(JST["templates/answer"]({ data: data }))
    else if data['data']['comment'] && gon.curret_user_id != data['data']['comment'].user_id
      if data['data']['comment'].commentable_type == "Question"
        $('.question-comments .comments-list').append(JST["templates/comment"]({ data: data }))
      else if data['data']['comment'].commentable_type == "Answer"
        $(".answers .all-answers .answer-instance#answer-info-#{data['data']['commentable_id']} .answer-comments .comments-list").append(JST["templates/comment"]({ data: data}))
