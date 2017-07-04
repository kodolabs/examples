class Setting < RailsSettings::Base
  source SETTINGS_FILE
  namespace Rails.env

  validates :value, numericality: { greater_than: 0 }, if: :numeric?

  def self.grouped_data
    grouped = get_all.group_by { |k, _| k.split('.').first }.sort_by { |k, _| k }
    grouped.map do |k, v|
      [k, v.map { |kk, vv| [kk.split('.')[1..-1].join, vv] }.to_h]
    end.to_h
  end

  private

  def numeric?
    var.in?(%w(
      general.trial_length_days
      referral_program.referrer_amount referral_program.referral_amount
    ))
  end
end
