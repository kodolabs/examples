class Omniauth::Twitter
  def initialize(user, request)
    @user = user
    @customer = user.customer
    request = request
    auth_hash = request.env['omniauth.auth']
    @uid = auth_hash['uid']
    @token = auth_hash['credentials']['token']
    @secret = auth_hash['credentials']['secret']
    @name = auth_hash['info']['name']
    @username = auth_hash['info']['nickname']
    @provider_id = Provider.twitter.id
  end

  def call
    check_if_allowed

    connect_account
    create_pages

    @account
  end

  private

  def check_if_allowed
    raise AccountsLimitReachedException if @customer.reached_account_limit?
    raise AccountIsNotUniqException if Account.connected.where(uid: @uid, provider_id: @provider_id).any?
  end

  def connect_account
    @account = Accounts::Connect.new(@customer, uid: @uid,
                                                token: @token,
                                                secret: @secret,
                                                provider_id: @provider_id,
                                                name: @name,
                                                username: @username).query
  end

  def create_pages
    page = Page::FindOrCreateAndFetch.new(@provider_id, 'handle', @username).call
    PostsWorker.perform_async(page.id, {})
    PageWorker.new.perform(page.id)
    create_owned_page(page)
  end

  def create_owned_page(page)
    page = OwnedPage.find_or_create_by(page_id: page.id)
    page.account = @account
    page.save if page.changed?
  end
end
