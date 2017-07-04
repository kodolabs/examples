class Domains::TrackUptimeChange
  include Interactor::Organizer

  organize Tasks::CreateDomainUptimeTask
end
