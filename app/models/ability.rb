# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user = user

    if user
      user.admin? ? admin_abilities : user_abilities
    else
      guest_abilities
    end
  end

  def guest_abilities
    can :read, :all
    can :create, :create_email
    can :authenticate, :oauth_provider
    can :access_profile, :me
  end

  def admin_abilities
    can :manage, :all
  end

  def user_abilities
    guest_abilities

    can :create, [Question, Answer, Comment]
    can :update, [Question, Answer, Comment], user_id: user.id
    can :destroy, [Question, Answer, Comment], user_id: user.id
    can :destroy, Link do |item|
      user.author_of?(item.linkable)
    end

    can :destroy, ActiveStorage::Attachment do |attachment|
      user.author_of?(attachment.record)
    end

    can :like, [Question, Answer] do |item|
      ratable?(item) && item.rating.not_been_rated_this_way?(user, Rating::RATED_UP)
    end

    can :dislike, [Question, Answer] do |item|
      ratable?(item) && item.rating.not_been_rated_this_way?(user, Rating::RATED_DOWN)
    end

    can :unlike, [Question, Answer] do |item|
      ratable?(item) && item.rating.rated?(user)
    end

    can :choose_best, Answer do |answer|
      user.author_of?(answer.question)
    end

    can :check_rewards, User, id: user.id
  end

  def ratable?(item)
    !user.author_of?(item)
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
