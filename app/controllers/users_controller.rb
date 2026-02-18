class UsersController < ApplicationController
  def index
    @sizes      = Company.distinct.pluck(:size)
    @industries = Company.distinct.pluck(:industry)
    @products   = Product.order(:name).pluck(:name, :id)

    @users = User.includes(:company, user_product_interests: :product)

    if params[:search].present?
      @users = @users.where("users.email LIKE ?", "%#{params[:search]}%")
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
  end

end