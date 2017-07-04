class Profile::PollsController < Profile::OrganiserBaseController
  before_action :find_poll, only: [:show, :edit, :update]

  def index
    @polls = @event.polls.ordered
  end

  def new
    @poll = Poll.new
    @poll.answers.build
  end

  def create
    @poll = @event.polls.new(poll_params)
    if @poll.save
      PollQrcodeService.new(@poll.id).generate_code
      redirect_to profile_event_polls_path,
        flash: { success: 'Poll successfully created' }
    else
      render :new
    end
  end

  def edit
    authorize @poll, :edit?
  end

  def update
    authorize @poll, :edit?
    if @poll.update(poll_params.merge(event_id: params[:event_id]))
      redirect_to profile_event_polls_path,
        flash: { success: 'Poll successfully updated' }
    else
      render :new
    end
  end

  private

  def poll_params
    params.require(:poll).permit(
      :title, :question, :multiple_choice, :status,
      answers_attributes: %i(id position value _destroy)
    )
  end

  def find_poll
    @poll = @event.polls.find(params[:id])
  end
end
