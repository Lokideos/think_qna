# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

users = User.create([{ email: 'test@test.com', password: '111111', confirmed_at: DateTime.now },
                     { email: 'dio@theworld.com', password: 'theworld', confirmed_at: DateTime.now },
                     { email: 'shaper@atlas.com', password: 'theatlas', confirmed_at: DateTime.now },
                     { email: 'jojo@bizzare.com', password: 'bizzare', confirmed_at: DateTime.now, admin: true }])

questions = Question.create([{ title: 'Galactic Empire Weapon',
                               body: "What's Galactic Empire most dangerous weapon?",
                               user: users[0] },
                             { title: 'First programming language',
                               body: 'What programming language to learn first?',
                               user: users[0] },
                             { title: 'Lightsaber color',
                               body: 'Who prefers red color of lightsabers?',
                               user: users[1] },
                             { title: 'Jostar',
                               body: 'Where is JoJo?',
                               user: users[1] }])

answers = Answer.create([{ body: "It's stormtrooper", user: users[1], question: questions[0] },
                         { body: "It's the Death Star", user: users[2], question: questions[0], best: true },
                         { body: 'Try Ruby', user: users[2], question: questions[1] },
                         { body: "It's green", user: users[0], question: questions[2] },
                         { body: 'Or orange', user: users[0], question: questions[2] },
                         { body: "It's obviously red", user: users[2], question: questions[2] },
                         { body: 'Behind you', user: users[2], question: questions[3] }])

# Question Ratings
questions[0].rating.score_up(users[1])
questions[0].rating.score_up(users[2])
questions[3].rating.score_down(users[0])

# Answer Ratings
answers[0].rating.score_down(users[0])
answers[0].rating.score_down(users[2])
answers[1].rating.score_up(users[1])
answers[2].rating.score_up(users[0])
answers[2].rating.score_up(users[1])
answers[4].rating.score_up(users[1])
answers[4].rating.score_down(users[2])
