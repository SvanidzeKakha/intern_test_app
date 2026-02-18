class ImportsController < ApplicationController
  def new
    @users = User.includes(:company, :user_product_interests, :products)
  end

  def create
    file = params[:file]

    if file.blank?
      redirect_to new_import_path, alert: "Please select a CSV file"
      return
    end

    Csv::UserImport.call(file)

    redirect_to users_path, notice: "CSV imported successfully"
  rescue StandardError => e
    redirect_to new_import_path, alert: e.message
  end
end
