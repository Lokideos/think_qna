# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Question, type: :model do
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:links).dependent(:destroy) }
  it { should have_many(:comments).dependent(:destroy) }
  it { should have_one(:reward).dependent(:destroy) }
  it { should belong_to :user }

  it { should validate_presence_of :title }
  it { should validate_presence_of :body }

  it { should accept_nested_attributes_for :links }
  it { should accept_nested_attributes_for :reward }

  it 'have many attached file' do
    expect(Question.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
  end

  it_behaves_like 'Concern Ratable'

  it 'triggers :broadcast_question after create & commit' do
    question_broadcast_data = 'Prepared question hash for broadcasting'
    question = build(:question)
    expect(question).to receive(:broadcast_question).and_return(
      ActionCable.server.broadcast('all_questions', data: question_broadcast_data)
    )
    question.save
  end
end
