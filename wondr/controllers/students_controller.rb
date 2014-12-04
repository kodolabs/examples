class Backend::StudentsController < Backend::BaseController

  def index
    students = Student.sorted.includes(:klass).includes(:parents)
    render_for_api :default, json: students
  end

  def create
    student = Student.new student_params

    respond_to do |format|
      format.json do
        if student.save
          render_for_api :default, json: student
        else
          render json: { errors: student.errors }, status: 406
        end
      end
    end
  end

  def update
    student = Student.find params[:id]

    respond_to do |format|
      format.json do
        if student.update_attributes student_params
          render_for_api :default, json: student
        else
          render json: { errors: student.errors }, status: 406
        end
      end
    end
  end

  def destroy
    student = Student.find params[:id]

    if student.destroy
      render json: {}
    else
      render json: { errors: student.errors}, status: 406
    end
  end

  protected

  def student_params
    params.require(:student).permit(:id, :first_name, :last_name, :klass_id, :id_number, :dob, :avatar, :parent_ids => [])
  end

end
