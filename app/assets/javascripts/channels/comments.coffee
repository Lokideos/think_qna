App.comments = App.cable.subscriptions.create { channel: "CommentsChannel", question_id: gon.question_id },
  received: (data) ->
    if data['data']['comment'].user_id != gon.current_user_id
      if data['data']['comment'].commentable_type == "Question"
        $('.question-comments .comments-list').append(JST["templates/comment"]({ data: data }))
      else if data['data']['comment'].commentable_type == "Answer"
        $(".answers .all-answers .answer-instance#answer-info-#{data['data']['commentable_id']} .answer-comments .comments-list").append(JST["templates/comment"]({ data: data}))
