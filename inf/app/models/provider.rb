class Provider < ApplicationRecord
  scope :ordered, -> { order(name: :asc) }

  def self.facebook
    find_by(name: 'facebook')
  end

  def self.twitter
    find_by(name: 'twitter')
  end

  def self.google
    find_by(name: 'google')
  end

  def self.linkedin
    find_by(name: 'linkedin')
  end

  def twitter?
    name == 'twitter'
  end

  def facebook?
    name == 'facebook'
  end

  def google?
    name == 'google'
  end

  def linkedin?
    name == 'linkedin'
  end

  def self.for_creating_pages
    where.not(name: %w(linkedin google))
  end
end
