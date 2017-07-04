class Domains::TrackHackStatusChange
  include Interactor::Organizer

  organize Tasks::CreateDomainHackedTask
end
