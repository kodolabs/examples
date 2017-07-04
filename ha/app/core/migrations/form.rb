module Migrations
  class Form < Rectify::Form
    attribute :migrate_to_new_domain, Boolean
    attribute :remove_articles, Boolean
    attribute :domain_id, Integer
    attribute :reason, String
    attribute :blog_type, String
    attribute :status, String
    attribute :host_action, String

    validates :blog_type, presence: true
    validates :domain_id, :status, presence: true, if: :migrate_to_new_domain
    validates_inclusion_of :status, in: Domain.statuses, if: :migrate_to_new_domain
    validates_inclusion_of :host_action, in: Migrations::Enum.host_actions.stringify_keys,
                                         allow_blank: true, unless: :migrate_to_new_domain
    validates_inclusion_of :blog_type, in: Host.blog_types
  end
end
