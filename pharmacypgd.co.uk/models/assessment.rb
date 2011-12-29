class Assessment < ActiveRecord::Base

  MAX_INVALID_ANSWERS = 5
  STATUSES = %w{incomplete complete failed expired}

  belongs_to :user
  belongs_to :pgd

  default_scope order("created_at DESC") # latest first

  scope :by_pgd, lambda {|pgd_id| where("pgd_id = ?", pgd_id) unless pgd_id.blank? }
  scope :complete, where("status = 'complete'")
  scope :active, lambda { where("valid_until >= ?", Date.today) }

  state_machine :status, :initial => 'incomplete' do

    before_transition   :incomplete => :complete,   :do => :set_dates
    after_transition    :incomplete => :complete,   :do => :on_complete
    after_transition    any         => :incomplete, :do => :init_answers

    event :reset do
      transition all => :incomplete
    end

    event :complete do
      transition :incomplete => :complete
    end

    event :fail do
      transition :incomplete => :failed
    end
  end

  serialize :answers

  def questions
    @questions ||= pgd.questions
  end

  def incomplete?
    status != 'complete'
  end

  def active?
    valid_until >= Date.today
  end

  def answer(user_answer)
    question = questions.find(user_answer[:question_id])
    return nil if question.blank?

    response = AnswerResponse.new
    response.question_id = question.id

    self.init_answers if answers.blank?

    if is_repeated?(question.id)
      response.response_message = 'You cannot change previous answer'
      response.result = false
    else
      result = question.correct?(user_answer[:choice])
      unless result
        self.answers['incorrect_answers_count'] += 1
        self.status = 'failed' if self.answers['incorrect_answers_count'] >= MAX_INVALID_ANSWERS
      end
      response.result, response.response_message = result, question.get_response_for(result)
      check_if_complete
      self.save
    end
    response.assessment_status = self.status
    response
  end

protected

  def on_complete
    History.create_assessment(self.user, self.pgd)
  end

  def is_repeated?(id)
    if self.answers['questions'].include?(id)
      true
    else
      self.answers['questions'] << id
      false
    end
  end

  def check_if_complete
    if self.answers['questions'].length == self.questions.count && self.status == 'incomplete'
      self.complete
    end
  end

  def set_dates
    self.completed_at = Date.today
    self.valid_until = self.completed_at + 6.weeks
  end

  def init_answers
    self.answers = {}
    self.answers['questions'] = []
    self.answers['incorrect_answers_count'] = 0
    save
  end

end
