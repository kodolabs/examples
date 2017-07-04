class DemandsController < ApplicationController
  include PatientHelper

  before_action :authenticate
  layout false

  def new
    if params[:hospital_id].present?
      assign_hospital_variables
    else
      assign_multiple_hospital_variables
    end
    @demand = build_demand
  end

  def create
    assign_selected_procedures
    @demand = build_demand(demand_params)
    if @demand.create_with_enquiries
      patient = @demand.patient
      path = proposals_path(patient)
      has_preop = !!patient.preop_form
      render js: "window.onDemandCreated(#{patient.id}, #{has_preop}, '#{path}')"
    else
      render 'new'
    end
  end

  private

  def assign_hospital_variables
    @hospital = Hospital.find(params[:hospital_id])
    @procedure = @hospital.procedures.find(params[:procedure_id])
  end

  def assign_multiple_hospital_variables
    @procedure = Procedure.find_by(slug: params[:procedure])
  end

  def assign_selected_procedures
    @procedure_ids = demand_params[:procedure_ids].dup
    if demand_params[:hospital_id].present?
      assign_hospital_selected_procedures
    else
      assign_multiple_hospital_selected_procedures
    end
  end

  def assign_hospital_selected_procedures
    @hospital = Hospital.find(demand_params[:hospital_id])
    @procedure = @hospital.procedures.find_by(id: @procedure_ids.shift)
    @selected_procedures = @hospital.procedures.where(id: @procedure_ids)
  end

  def assign_multiple_hospital_selected_procedures
    @procedure = Procedure.find_by(id: @procedure_ids.shift)
    @selected_procedures = Procedure.where(id: @procedure_ids)
  end

  def authenticate
    authenticate_user! unless current_facilitator
  end

  def build_demand(params = {})
    return facilitator_demand(params) if current_facilitator
    current_user.patient.demands.new(params)
  end

  def facilitator_demand(params)
    demand = Demand.new(params)
    demand.build_patient(facilitator_id: current_facilitator.id) if params.empty?
    demand
  end

  def demand_params
    params.require(:demand).permit(
      :date_from, :date_to, :description, :purpose, :question, :hospital_id, :patient_id,
      procedure_ids: [], patient_attributes: [:first_name, :last_name, :facilitator_id],
      hospital_ids: []
    )
  end
end
