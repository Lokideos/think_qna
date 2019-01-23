App.questions = App.cable.subscriptions.create "QuestionsChannel",
  received: (data) ->
    $('.all-questions').append(JST["templates/question"]({ data: data }))
