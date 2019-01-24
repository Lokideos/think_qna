# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe User, type: :model do
  context 'Associations' do
    it { should have_many(:questions) }
    it { should have_many(:answers) }
    it { should have_many(:rewards) }
    it { should have_many(:comments) }
    it { should have_many(:rating_changes) }
    it { should have_many(:ratings).through(:rating_changes) }
  end

  context 'Methods' do
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

    describe '#add_reward' do
      let(:user) { create(:user) }
      let(:question) { create(:question) }
      let(:reward) { create(:reward, question: question) }

      it "should add reward to user's rewards" do
        expect { user.add_reward(reward) }.to change(user.rewards, :count).by(1)
      end

      it "should not add reward to user's rewards if user already posses this reward" do
        user.add_reward(reward)
        expect { user.add_reward(reward) }.to_not change(user.rewards, :count)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
