class Domains::TrackIndexStatusChange
  include Interactor::Organizer

  organize Alerts::CreateDomainIndexAlert, Campaigns::UpdateCampaignsHealth, Tasks::CreateDomainDeindexedTask
end
