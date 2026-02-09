require "csv"
module Csv
  class UserImport
    def self.call(file)
      new(file).call
    end
    
    def initialize(file)
      @file = file
    end
    
    def call
      CSV.foreach(@file.path, headers: true) do |row|
        ActiveRecord::Base.transaction do
          import_row(row)
        end
      end
    end
    
    private
    
    def import_row(row)
      company = resolve_company(row)
      user    = resolve_user(row, company)
      resolve_interests(row, user)
    end
    
    def resolve_company(row)
      new_name = row["company_name"].strip
      company = Company.find_or_create_by!(
        industry: row["company_industry"],
        size: row["company_size"]
      ) do |c|
        c.name = new_name
      end
      
      current_name = company.company_names.find_by(is_current: true)
      
      if current_name.nil?
        CompanyName.create!(
          company: company,
          name: company.name,
          is_current: true
        )
        return company
      end
      
      return company if current_name.name == new_name
      
      CompanyName.transaction do
        current_name.update!(is_current: false)
        CompanyName.find_or_create_by!(
          company: company,
          name: new_name
        ).update!(is_current: true)
        company.update!(name: new_name)
      end
      
      company
    end
    
    def resolve_user(row, company)
      User.find_or_create_by!(email: row["email"]) do |user|
        user.fname   = row["fname"]
        user.lname   = row["lname"]
        user.phone   = row["phone"]
        user.country = row["country"]
        user.company = company
      end
    end
    
    def resolve_interests(row, user)
      return if row["products_of_interest"].blank?
      
      new_product_names = row["products_of_interest"].split(";").map(&:strip)
      existing_interests = user.user_product_interests.includes(:product).order(:id)
      
      new_product_names.each_with_index do |new_name, index|
        if existing_interests[index]
          existing_product = existing_interests[index].product
          resolve_product(existing_product, new_name)
        else
          product = find_create_product(new_name)
          UserProductInterest.create!(user: user, product: product)
        end
      end
      
      if new_product_names.length < existing_interests.length
        existing_interests[new_product_names.length..-1].each(&:destroy)
      end
    end

    def resolve_product(product, new_name)
      return if product.name == new_name
      
      existing_by_name = ProductName.find_by(name: new_name)
      return if existing_by_name && existing_by_name.product_id != product.id

      current_name = product.product_names.find_by(is_current: true)

      ProductName.transaction do
        current_name.update!(is_current: false) if current_name
        ProductName.find_or_create_by!(product: product, name: new_name).update!(is_current: true)
        product.update!(name: new_name)
      end
    end
    
    def find_create_product(product_name)
      existing_product_name = ProductName.find_by(name: product_name)
      
      if existing_product_name
        existing_product_name.product
      else
        product = Product.create!(name: product_name)
        ProductName.create!(
          product: product,
          name: product_name,
          is_current: true
        )
        product
      end
    end
  end
end