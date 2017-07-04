class Migrations::Run
  include Interactor::Organizer

  organize Migrations::CreateHost, Migrations::UpdateArticles, Migrations::CompleteTasks
end
