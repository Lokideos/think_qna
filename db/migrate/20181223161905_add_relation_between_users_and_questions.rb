# frozen_string_literal: true

class AddRelationBetweenUsersAndQuestions < ActiveRecord::Migration[5.2]
  def change
    add_belongs_to :questions, :user
  end
end
