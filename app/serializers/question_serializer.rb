# frozen_string_literal: true

class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :created_at, :updated_at
  belongs_to :user
  has_many :comments, serializer: ShortCommentSerializer
  has_many :files, serializer: FileSerializer
  has_many :links
end
