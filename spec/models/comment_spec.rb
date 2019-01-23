# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  it { should belong_to :commentable }
  it { should belong_to :user }

  it { should validate_presence_of :body }

  it 'triggers :broadcast_comment on create & commit' do
    comment = build(:comment)
    expect(comment).to receive :broadcast_comment
    comment.save
  end
end
