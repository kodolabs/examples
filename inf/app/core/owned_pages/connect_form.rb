# This form used on post request

class OwnedPages::ConnectForm < Rectify::Form
  attribute :pages, Hash
  attribute :account
  validate :check_existing_pages

  def check_existing_pages
    return if existing_page.blank?
    errors.add(:base, I18n.t('account.invalid.page_exists'))
  end

  def unchecked_pages
    @uncheked_pages ||= pages.select { |_i, param| param['checked'].blank? }.map { |_i, param| param }
  end

  def checked_pages
    @checked_pages ||= pages.select { |_i, param| param['checked'].present? }.map { |_i, param| param }
  end

  def existing_page
    return nil if checked_pages.blank?
    checked_pages.find do |page|
      handle = page['handle']
      uid = page['uid']
      provider = account.provider.name
      existing = Page.send(provider).find_by(uid: uid) if uid.present?
      existing ||= Page.send(provider).find_by(handle: handle) if handle.present?
      existing.presence && existing.owned_pages.connected.where.not(account: account).any?
    end
  end
end
