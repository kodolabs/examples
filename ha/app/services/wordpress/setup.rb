class Wordpress::Setup
  include Interactor::Organizer

  organize Wordpress::UploadPlugin, Wordpress::ActivatePlugin
end
