class Domain < ApplicationRecord
  belongs_to :network
  has_one :host, -> { where('hosts.active') }
  has_one :blog, through: :host
  has_many :monitorings, dependent: :destroy
  has_many :alerts, as: :alertable, dependent: :destroy
  has_many :hosts, dependent: :destroy
  has_many :tasks, as: :taskable, dependent: :destroy
  belongs_to :dns_account, class_name: 'Account', foreign_key: :dns_account_id

  enum hack_status: Domains::Enum.hack_statuses
  enum uptime_status: Domains::Enum.uptime_statuses
  enum index_status: Domains::Enum.index_statuses
  enum expiration_status: Domains::Enum.expiration_statuses
  enum status: Domains::Enum.statuses
  enum source: Domains::Enum.sources

  scope :ordered, -> { order(expires_at: :asc) }
  scope :valid, lambda {
                  where(uptime_status: :success)
                    .where(index_status: :indexed)
                }
  scope :invalid, lambda {
                    where.not(
                      'uptime_status = ? AND index_status = ?',
                      Domains::Enum.uptime_statuses[:success],
                      Domains::Enum.index_statuses[:indexed]
                    )
                  }
  scope :bad_uptime, lambda {
                       where(uptime_status:
                         [
                           Domains::Enum.uptime_statuses[:unavailable],
                           Domains::Enum.uptime_statuses[:error]
                         ])
                     }
  scope :domain_search, ->(domain) { where('name ILIKE ?', "%#{domain}%") }
  scope :autocomplete_domain_search, ->(domain) { where('name ILIKE ?', "#{domain}%") }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_networks, ->(*ids) { where(network_id: ids) }
  scope :live, -> { where('domains.status <> ?', Domains::Enum.statuses[:inactive]) }

  def self.statuses_collection
    statuses.keys.map do |status|
      [status, status&.titleize]
    end
  end

  def self.status_collection_for
    statuses.keys.map do |status|
      [status&.titleize, status]
    end
  end

  def collection_for_migrate
    Domain.where(network_id: network_id).where.not(id: id).order(:name).pending.map do |domain|
      [domain.name, domain.id]
    end.uniq
  end

  def self.migration_types
    [
      [false, I18n.t('domains.form.migrate_to_same_domain')],
      [true, I18n.t('domains.form.migrate_to_new_domain')]
    ]
  end

  def activate!
    return active! if activated_at.present?
    update!(activated_at: Time.zone.now, status: :active)
  end

  def self.sources_collection
    sources.keys.map do |source|
      [source, source&.titleize]
    end
  end

  def not_indexed_days
    return 0 unless not_indexed?
    date = monitorings&.indexed&.first&.last_status_changed_at&.to_date
    (Time.zone.today - date).to_i if date.present?
  end

  def live?
    status.to_sym != :inactive
  end

  def to_selectize_hash
    { label: name, value: id }
  end
end
