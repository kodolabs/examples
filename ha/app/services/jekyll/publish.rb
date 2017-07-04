class Jekyll::Publish
  include Interactor::Organizer

  organize Jekyll::Setup, Jekyll::AddContent, Jekyll::Build, Jekyll::UploadToServer, Jekyll::Finish
end
