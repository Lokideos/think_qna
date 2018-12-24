# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:questions) }
  it { should have_many(:answers) }

  describe '#author_of?' do
    let(:user) { create(:user) }
    let(:non_author) { create(:user) }
    let(:question) { create(:question, user: user) }

    context 'For author of the question' do
      it 'should return true' do
        expect(user).to be_author_of(question)
      end
    end

    context 'For user, who is not author of the question' do
      it 'should return false' do
        expect(non_author).to_not be_author_of(question)
      end
    end
  end
end
