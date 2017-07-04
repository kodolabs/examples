class TaskDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include Rails.application.routes.url_helpers
  delegate_all

  def flag_tag
    if object.flag?
      h.link_to(task_path(object), class: 'rt-table__flag-link flag-link flag-link--active', 'data-object-name': 'task[flag]') do
        h.render('shared/new_design/icons/table_flag')
      end
    else
      h.link_to(task_path(object), class: 'rt-table__flag-link flag-link', 'data-object-name': 'task[flag]') do
        h.render('shared/new_design/icons/table_flag')
      end
    end
  end

  def formatted_description
    object.description.to_s.gsub("\n", '<br/>').html_safe
  end

  def type_sym
    object.general? ? 'G' : 'RI'
  end

  def created_by_name
    object.created_by&.decorate&.safe_name
  end

  def assigned_to_name
    object.assigned_to&.decorate&.safe_name
  end

  def format_due_date
    (long_format(:due_date) + (object.overdue? ? overdue_icon : '')).html_safe if object.due_date.present?
  end

  def overdue_icon
    h.content_tag(:span, h.render('shared/new_design/icons/exclamation'), class: 'rt-table__icon')
  end

  def long_format(attr)
    I18n.l(object.send(attr), format: I18n.t('time.formats.site.date_full'))
  end

  def short_format(attr)
    object.send(attr)&.strftime(I18n.t('time.formats.site.date_full'))
  end

  def button_name
    object.new_record? ? t('customer.shared.forms.create') : I18n.t('customer.tasks.form.edit')
  end

  def review_error?
    object.errors.any? && review_errors.present?
  end

  def review_errors
    object.errors.messages[:review_id]
  end

  def review_class
    klass = review_error? ? 'has-error' : ''
    klass += 'hidden' if object.general?
    klass
  end

  def disable_field?(field)
    case field
    when 'review_id', 'task_type'
      return true if object.persisted?
    else
      return false
    end
    false
  end

  def show_field?(field)
    case field
    when 'task_type', 'review_id'
      return false if modal?
    else
      true
    end
    true
  end

  def assigned_wrapper_class
    modal? ? 'col-lg-6' : 'col-lg-4'
  end

  def due_date_wrapper_class
    klass = modal? ? 'col-lg-6' : 'col-lg-4'
    "#{klass} due-date-wrapper"
  end

  def modal?
    @modal || controller_name == 'reviews'
  end

  def modal!
    @modal = true
    self
  end

  def form_resource_for(review)
    review.present? ? [review, object] : object
  end

  def cancel_path
    modal? ? '#' : :back
  end

  def review_collection
    if object.review.present?
      review = object.review.decorate
      [review.safe_short_title, task.review_id]
    else
      []
    end
  end

  def due_date_distance_in_words
    return nil if object.due_date.blank?
    if object.overdue?
      to_date = Date.today
      from_date = object.due_date.to_date
      I18n.t 'tasks.over_due.prev.x_days', count: (to_date - from_date).to_i
    else
      to_date = object.due_date.to_date
      from_date = Date.today
      I18n.t 'tasks.over_due.next.x_days', count: (to_date - from_date).to_i
    end
  end
end
