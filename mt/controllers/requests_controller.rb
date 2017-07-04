class Manager::RequestsController < Manager::BaseController
  before_action :assign_enquiry, only: [:reject, :cancel]

  def index
    @enquiries = enquiries(params[:type])
  end

  def show
    @enquiry = current_hospital.enquiries.requests.find(params[:id]).decorate
    @procedures = current_hospital.procedures if @enquiry.pending?
  end

  def accept
    proposal = Proposal.new(proposal_params)
    if proposal.save
      proposal.enquiry.make_proposal!
      redirect_to manager_requests_path
    else
      render :index
    end
  end

  def reject
    @enquiry.decline_enquiry!(enquiry_params[:state_comment])
    if request.xhr?
      status = @enquiry.errors.any? ? 400 : 200
      render nothing: true, status: status
    else
      redirect_to manager_requests_path
    end
  end

  def cancel
    @enquiry.cancel_proposal!
    if request.xhr?
      render nothing: true
    else
      redirect_to manager_requests_path
    end
  end

  private

  def enquiries(type)
    type = 'new' if type.blank?
    current_hospital.enquiries.requests(type).ordered.decorate
  end

  def assign_enquiry
    @enquiry ||= current_hospital.enquiries.find_by(id: enquiry_params[:id])
  end

  def enquiry_params
    params.require(:enquiry).permit(:id, :state_comment)
  end

  def proposal_params
    params.require(:proposal).permit(
      :enquiry_id, :start_date, :days_in_hospital,
      proposal_procedures_attributes: [:procedure_id, :price],
      details: ProposalDetails::FIELDS.keys
    )
  end
end
