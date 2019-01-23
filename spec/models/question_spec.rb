# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Question, type: :model do
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:links).dependent(:destroy) }
  it { should have_many(:comments).dependent(:destroy) }
  it { should have_one(:reward).dependent(:destroy) }
  it { should have_one(:rating).dependent(:destroy) }
  it { should belong_to :user }

  it { should validate_presence_of :title }
  it { should validate_presence_of :body }

  it { should accept_nested_attributes_for :links }
  it { should accept_nested_attributes_for :reward }

  it 'have many attached file' do
    expect(Question.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
  end

  describe '#create_rating' do
    it 'creates rating after question creation' do
      expect { create(:question) }.to change(Rating, :count).by(1)
    end

    it 'creates association to new rating for question after creating question' do
      question = create(:question)

      expect(question.rating).to be_a(Rating)
    end
  end

  it 'triggers :broadcast_question after create & commit' do
    question = build(:question)
    expect(question).to receive :broadcast_question
    question.save
  end
end
# rubocop:enable Metrics/BlockLength
