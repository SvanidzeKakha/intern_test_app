class UsersController < ApplicationController
  def index
    @sizes      = Company.distinct.pluck(:size)
    @industries = Company.distinct.pluck(:industry)
    @products   = Product.order(:name).pluck(:name, :id)

    @users = User.includes(:company, user_product_interests: :product)

    if params[:email].present?
      @users = @users.where("users.email LIKE ?", "%#{params[:email]}%")
    end

    if params[:sizes].present?
      @users = @users.joins(:company)
                    .where(companies: { size: params[:sizes] })
    end

    if params[:industries].present?
      @users = @users.joins(:company)
                    .where(companies: { industry: params[:industries] })
    end

    if params[:product_ids].present?
      @users = @users.joins(:products)
                    .where(products: { id: params[:product_ids] })
    end

    @users = @users.distinct
    @users = @users.paginate(page: params[:page], per_page: 100)

  end

  def download_csv
    user = User
            .includes(:company, :products)
            .where(id: params[:user_ids])
    
    csv = CSV.generate(headers: true) do |csv|
      csv << ["Email", "First name", "Last name", "Phone", "Country", "Company", "Industry", "Size", "Intersts"]
  
      user.each do |user|
        csv << [
          user.email,
          user.fname,
          user.lname,
          user.phone,
          user.country,
          user.company.name,
          user.company.industry,
          user.company.size,
          user.products.pluck(:name).join(", ")
        ]      
      end
    end


    send_data csv,
              filename: "users-#{Date.today}.csv",
              type: "text/csv"
  end
end