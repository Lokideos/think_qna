App.question = App.cable.subscriptions.create { channel: "QuestionChannel", question_id: gon.question_id },
  received: (data) ->
    if data['data']['answer'].user_id != gon.current_user_id
      $('.all-answers .answers-list').append(JST["templates/answer"]({ data: data }))