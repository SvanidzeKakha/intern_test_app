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

end