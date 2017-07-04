class Profile < ApplicationRecord
  SYNC_DB_ATTRS = %w[user_id full_name]

  include DbSyncable
  include Profilable

  belongs_to :profession
  belongs_to :user
  has_many :topics, through: :profile_topics
  has_many :profile_topics, dependent: :destroy
  has_many :interest_topics, through: :interest_profile_topics, source: 'topic', class_name: '::Topic'
  has_many :interest_profile_topics, -> { interest }, class_name: '::ProfileTopic', dependent: :destroy
  has_many :speciality_topics, through: :speciality_profile_topics, source: 'topic', class_name: '::Topic'
  has_many :speciality_profile_topics, -> { speciality }, class_name: '::ProfileTopic', dependent: :destroy
  has_many :workplaces, through: :profile_workplaces
  has_many :profile_workplaces, dependent: :destroy
  has_many :sub_speciality_topics,
    through: :sub_speciality_profile_topics,
    source: 'topic',
    class_name: '::Topic'
  has_many :sub_speciality_profile_topics, -> { sub_speciality },
    class_name: '::ProfileTopic',
    dependent: :destroy

  validates :phone,
    phony_plausible: true,
    format: { with: /\A\+\d+/, message: 'invalid number' }

  phony_normalize :phone

  def update_fields(fields)
    updated_data = form_params.merge(fields.stringify_keys)
    update_attributes(data: updated_data.to_json)
  end
end
