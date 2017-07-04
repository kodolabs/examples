class Hospital < ActiveRecord::Base
  acts_as_messageable

  include Elasticsearch::Model
  include SearchIndex
  include FriendlyId
  include PgSearch
  attr_accessor :amenities_tags, :plus_features_tags, :accreditations_tags, :img_ids

  belongs_to :location
  has_one :manager
  has_many :amenity_hospitals
  has_many :amenities, through: :amenity_hospitals
  has_many :hospital_plus_features
  has_many :plus_features, through: :hospital_plus_features
  has_many :hospital_procedures
  has_many :procedures, through: :hospital_procedures
  has_many :enquiries
  has_many :accreditation_hospitals
  has_many :accreditations, through: :accreditation_hospitals
  has_many :images
  has_many :plus_payments, through: :enquiries
  has_many :cancellation_fees, through: :enquiries
  has_many :payments, through: :enquiries
  has_many :reviews, dependent: :destroy
  has_many :specialities, through: :hospital_procedures
  has_many :doctors

  accepts_nested_attributes_for :manager
  accepts_nested_attributes_for :doctors, allow_destroy: true

  validates :name, :location_id, :latitude, :longitude, presence: true
  validates :clinic_id, uniqueness: true, if: 'clinic_id.present?'

  scope :ordered, -> { order(:name) }
  scope :eager, -> { includes(:accreditations, :amenities, :plus_features) }
  scope :featured, -> { where(featured: true) }
  scope :visible, -> { where(visible: true) }
  scope :ordered_by_plus_partner, -> { order(plus_partner: :desc, name: :asc) }
  scope :admin_search, -> (q) { pg_search(q) if q.present? }

  after_save :set_amenities, :set_plus_features, :set_accreditations, :update_index, :assign_images
  after_destroy :remove_index
  after_touch :update_index

  mount_uploader :image, HospitalUploader

  friendly_id :slug_candidate, use: [:slugged, :finders]

  serialize :languages

  mapping do
    indexes :id, index: :not_analyzed, type: 'integer'
    indexes :name, type: 'string', index: :not_analyzed
    indexes :plus_partner, index: :not_analyzed, type: 'boolean'
    indexes :visible, index: :not_analyzed, type: 'boolean'
    indexes :city, type: 'string', index: :not_analyzed
    indexes :country, type: 'string', index: :not_analyzed
    indexes :region, type: 'string', index: :not_analyzed
    indexes :coordinates, type: 'geo_point'
    indexes :rating, type: 'integer', index: :not_analyzed
    indexes :procedures, type: 'nested', properties: {
      id: { index: :not_analyzed, type: 'integer' },
      price_from: { index: :not_analyzed, type: 'float' },
      price_to: { index: :not_analyzed, type: 'float' }
    }
  end

  pg_search_scope :pg_search, against: [:name], using: { tsearch: { prefix: true } }

  def hospital_procedure(procedure)
    hospital_procedures.where(procedure: procedure).first_or_initialize
  end

  def patients
    demands = Demand.where(id: enquiries.select(:demand_id))
    Patient.where(id: demands.select(:patient_id))
  end

  def as_indexed_json(_options = {})
    {
      id: id,
      name: name,
      plus_partner: plus_partner,
      visible: visible,
      city: location.name,
      country: location.parent.try(:name),
      region: location.root.name,
      coordinates: "#{latitude},#{longitude}",
      rating: rating,
      procedures: HospitalProcedure
        .joins(:procedure)
        .where('hospital_procedures.hospital_id = ? AND procedures.ancestry_depth IN(?)', id, [1, 2])
        .map do |hp|
                    {
                      id: hp.procedure_id,
                      price_from: hp.price_from,
                      price_to: hp.price_to
                    }
                  end
    }
  end

  def update_index
    __elasticsearch__.index_document
  end

  def remove_index
    __elasticsearch__.remove_document
  end

  def slug_candidate
    "#{name} #{location.name} #{location.parent.name}"
  end

  def mailboxer_name
    name
  end

  def mailboxer_email(object)
    return nil if object.sender == self
    manager.try(:email)
  end

  def update_rating
    total_rating = reviews.pluck(:average_rating).sum / reviews.count
    update_column(:rating, total_rating)
    update_index
  end

  private

  def set_amenities
    return unless amenities_tags

    ids = TagSaver.new(Amenity, amenities_tags).save
    self.amenity_ids = ids
  end

  def set_plus_features
    return unless plus_features_tags

    ids = TagSaver.new(PlusFeature, plus_features_tags).save
    self.plus_feature_ids = ids
  end

  def set_accreditations
    return unless accreditations_tags

    ids = TagSaver.new(Accreditation, accreditations_tags).save
    self.accreditation_ids = ids
  end

  def assign_images
    return unless img_ids

    img_ids.split(',').reject(&:blank?).each do |image_id|
      img = Image.find_by(id: image_id)
      img.update(hospital: self) if img
    end
  end
end
