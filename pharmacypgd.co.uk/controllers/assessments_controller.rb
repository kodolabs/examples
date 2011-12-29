class Pharmacist::AssessmentsController < Pharmacist::BaseController

  select_section :my_pgds
  select_section :pgd

  before_filter :resource, :only => [:show, :answer, :complete]

  def create

    # TODO: instead of creating a new assessment it might make more sense to do followoing:
    # - check for completed assessments and if yes - do not allow creating new one - redirect back to PGDs page
    # - check for any imcomplete assessments and reuse them
    pgd_id = params[:pgd_id]
    @pgd = Pgd.for(current_user).find(pgd_id) unless pgd_id.blank?

    redirect_to pharmacist_pgds_path and return if @pgd.blank?
    @assessment = current_user.assessments.build(:pgd_id => @pgd.id)

    if @assessment.save
      redirect_to pharmacist_assessment_path(@assessment)
    end
  end

  def show
    redirect_to pharmacist_pgds_path if @assessment.status == 'complete'
    @assessment.reset if ['incomplete', 'failed'].include?(@assessment.status)
  end

  def complete
    redirect_to pharmacist_pgds_path if @assessment.status == 'incomplete'
  end

  def answer
    respond_to do |format|
      format.json { render :json => @assessment.answer(params[:answer]) }
    end
  end

protected

  def resource
    @assessment = current_user.assessments.find(params[:id])
  end
end
