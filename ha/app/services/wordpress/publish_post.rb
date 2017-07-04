class Wordpress::PublishPost
  include Interactor::Organizer

  organize Wordpress::UploadPostImages, Wordpress::Publish
end
