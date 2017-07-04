class Procedure < ActiveRecord::Base
  include PgSearch
  include Elasticsearch::Model
  include FriendlyId
  include SearchIndex

  has_many :hospital_procedures, dependent: :destroy
  has_many :hospitals, through: :hospital_procedures
  has_many :demand_procedures
  has_many :demands, through: :demand_procedures
  has_many :proposal_procedures
  has_many :proposals, through: :proposal_procedures
  has_one :featured_procedure

  after_save :update_index
  after_update :touch_hospitals
  after_destroy :remove_index

  mount_uploader :image, ProcedureUploader

  has_ancestry cache_depth: true

  scope :indexable, -> { where(ancestry_depth: [1, 2]) }
  scope :ordered, -> { order(name: :asc) }

  pg_search_scope :pg_search, against: [:name], using: { tsearch: { prefix: true } }

  friendly_id :slug_candidate, use: [:slugged, :finders]

  settings analysis: Search::Base::ANALYSIS do
    mapping do
      indexes :id, index: :not_analyzed, type: 'integer'
      indexes :treatment, type: 'string', analyzer: 'partial', search_analyzer: :standard
      indexes :type_name, type: 'string', analyzer: 'partial', search_analyzer: :standard
      indexes :name, type: 'string', analyzer: 'partial', search_analyzer: :standard
      indexes :slug, index: :not_analyzed, type: 'string'
      indexes :depth, type: 'integer', index: :not_analyzed
      indexes :image_url, index: :not_analyzed, type: 'string'
    end
  end

  def update_index
    __elasticsearch__.index_document if ancestry_depth.positive?
  end

  def remove_index
    __elasticsearch__.remove_document
  end

  def touch_hospitals
    hospitals.map(&:touch)
  end

  def as_indexed_json(_options = {})
    defaults = { id: id, image_url: root.image.url(:small), depth: ancestry_depth, slug: slug }

    case ancestry_depth
    when 0
      defaults.merge(treatment: name, type_name: '', name: '')
    when 1
      defaults.merge(treatment: root.name, type_name: name, name: '')
    when 2
      defaults.merge(treatment: root.name, type_name: parent.name, name: name)
    end
  end

  def to_selectize_hash
    Selectize::Procedure::Builder.new(self).build
  end

  def image_url(version)
    root.image.url(version)
  end

  def slug_candidate
    name.to_s
  end
end
