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
      
      current_name = company.company_names.find_by(name: new_name)
      
      if current_name.nil?
        CompanyName.create!(
          company: company,
          name: new_name
        )
        return company
      end
      
      return company if current_name.name == new_name
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

      product_names = row["products_of_interest"].split(";").map(&:strip)

      create_missing_products(product_names)
      create_missing_interests(user, Product.where(name: product_names))
    end

    def create_missing_products(product_names)
      existing_products = Product.where(name: product_names)
      products_to_add = product_names - existing_products.pluck(:name) # substract existing product names from all product names
      products_to_add = products_to_add.map { |product_name| { name: product_name } } # convert into array of hashes for insert_all
      Product.insert_all(products_to_add)
    end

    def create_missing_interests(user, products_of_interest)
      existing_products_of_interest = user.user_product_interests.pluck(:product_id)
      new_products_of_interest = products_of_interest.pluck(:id)

      interests_to_add = new_products_of_interest - existing_products_of_interest
      rows = interests_to_add.map do |product_id|
        {
          user_id: user.id,
          product_id: product_id,
          created_at: Time.now,
          updated_at: Time.now
        }
      end
      
      UserProductInterest.insert_all(rows)
    end
  end
end