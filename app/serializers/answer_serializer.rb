# frozen_string_literal: true

class AnswerSerializer < ActiveModel::Serializer
  attributes :id, :body, :created_at, :updated_at, :user_id
end
