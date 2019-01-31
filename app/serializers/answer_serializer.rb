# frozen_string_literal: true

class AnswerSerializer < ActiveModel::Serializer
  attributes :id, :body, :created_at, :updated_at, :user_id
  has_many :comments, serializer: ShortCommentSerializer
  has_many :files, serializer: FileSerializer
  has_many :links
end
