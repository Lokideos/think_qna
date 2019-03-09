# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  it { should belong_to(:commentable).touch(true) }
  it { should belong_to :user }

  it { should validate_presence_of :body }

  it 'triggers :broadcast_comment on create & commit' do
    comment_broadcast_data = double('Prepared comment hash for broadcasting')
    question = create(:question)
    comment = build(:comment, commentable: question)
    expect(comment).to receive(:broadcast_comment).and_return(
      ActionCable.server.broadcast("comments_#{question.id}", data: comment_broadcast_data)
    )
    comment.save
  end
end
