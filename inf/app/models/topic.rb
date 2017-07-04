class Topic < ApplicationRecord
  SYNC_DB_ATTRS = %w[keyword speciality sub_speciality interest]

  include DbSyncable
  include PgSearch

  has_many :profile_topics, dependent: :destroy
  has_many :profiles, through: :profile_topics
  has_many :news_topics, dependent: :destroy
  has_many :news, through: :news_topics
  has_many :category_topics, dependent: :destroy
  has_many :categories, through: :caegory_topics

  scope :ordered, -> { order(:keyword) }
  scope :interest, -> { where(interest: true) }
  scope :speciality, -> { where(speciality: true) }
  scope :sub_speciality, -> { where(sub_speciality: true) }
  scope :topic_search, ->(q) { pg_search(q) if q.present? }
  scope :without_default, -> { where.not(keyword: ProfileBuilder::Spread::DEFAULT_TOPICS) }

  pg_search_scope :pg_search, against: [:keyword], using: { tsearch: { prefix: true } }

  def first_topic_type
    return topic_type_for(:speciality) if speciality.present?
    return topic_type_for(:sub_speciality) if sub_speciality.present?
    return topic_type_for(:interest) if interest.present?
    ProfileTopic.topic_types[:interest]
  end

  def self.default_topic_type
    ProfileTopic.topic_types[:interest]
  end

  def topic_type_for(topic_type)
    ProfileTopic.topic_types[topic_type]
  end
end
