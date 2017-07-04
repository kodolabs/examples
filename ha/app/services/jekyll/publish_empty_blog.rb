class Jekyll::PublishEmptyBlog
  include Interactor::Organizer

  organize Jekyll::Setup, Jekyll::Build, Jekyll::UploadToServer, Jekyll::Finish
end
