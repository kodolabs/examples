class Migrations::CompleteTasks
  include Interactor

  def call
    inspections = Tasks::Enum.categories.without(:payment).keys
    tasks = context.domain.tasks.by_category(inspections).pending
    tasks.each { |task| task.update(status: :done, user: context.user) }
  end
end
