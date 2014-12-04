class Backend::UploadsController < ApplicationController

  def create
    upload = Upload.new file: params[:file]

    if upload.save
      render_for_api :default, json: upload
    else
      render json: { errors: upload.errors }
    end
  end
end
