require_relative "../../../config/environment"
require "securerandom"

module Csv
  module UserImportMethodsUnderTest
    def resolve_interests(row, user)
      return if row["products_of_interest"].blank?

      new_product_names = row["products_of_interest"].split(";").map(&:strip)
      existing_interests = user.user_product_interests.includes(:product).order(:id)
      new_products = new_product_names.map do |new_name|
        find_create_product(new_name)
      end
      #get ids of existing interests and new ones from csv
      interests_id = existing_interests.map(&:product_id)
      product_id = new_products.map(&:id)

      #find what ids are to be added and removed
      to_add = product_id - interests_id
      to_remove = interests_id - product_id

      to_add.each do |id|
        UserProductInterest.create!(user: user, product_id: id)
      end

      to_remove.each do |id|
        user.user_product_interests.where(product_id: id).destroy_all
      end
    end

    #resolve_names not needed anymore because we now compare products inside resolve_interests
    #and previouse logic was flawed in the first place

    def find_create_product(product_name)
      existing_product_name = ProductName.find_by(name: product_name)

      if existing_product_name
        existing_product_name.product
      else
        product = Product.create!(name: product_name)
        ProductName.create!(
          product: product,
          name: product_name
        )
        product
      end
    end
  end

  class PlainInterestFailingTests
    include UserImportMethodsUnderTest

    def run
      tests = [
        :test_reordered_names_should_keep_distinct_products,
        :test_reordered_names_should_not_rename_existing_product
      ]

      puts "Running #{tests.length} failing tests..."

      failed = 0
      tests.each do |test|
        begin
          in_rollback_transaction { send(test) }
          puts "UNEXPECTED PASS: #{test}"
        rescue => e
          puts "EXPECTED FAIL: #{test}"
          puts "  #{e.class}: #{e.message}"
          failed += 1
        end
      end

      puts
      puts "Summary: #{failed}/#{tests.length} failed (expected: all fail)"
      failed == tests.length
    end

    # Bug: existing interest is matched by index, so 'Alpha' gets renamed to 'Beta'
    # instead of creating/reusing a separate Beta product.
    def test_reordered_names_should_keep_distinct_products
      user = create_user
      alpha = create_product("Alpha")
      UserProductInterest.create!(user: user, product: alpha)

      resolve_interests({ "products_of_interest" => "Beta;Alpha" }, user)

      interests = user.user_product_interests.includes(:product).order(:id)
      unique_products = interests.map(&:product_id).uniq.length
      raise "expected 2 distinct products, got #{unique_products}" unless unique_products == 2
    end

    # Same bug shown from another angle: existing product's canonical name is mutated.
    def test_reordered_names_should_not_rename_existing_product
      user = create_user
      alpha = create_product("Alpha")
      UserProductInterest.create!(user: user, product: alpha)

      resolve_interests({ "products_of_interest" => "Beta;Alpha" }, user)

      alpha.reload
      raise "expected Alpha to remain Alpha, got #{alpha.name}" unless alpha.name == "Alpha"
    end

    private

    def in_rollback_transaction
      ActiveRecord::Base.transaction do
        yield
        raise ActiveRecord::Rollback
      end
    end

    def create_user
      token = SecureRandom.hex(4)
      company = Company.create!(name: "company-#{token}", industry: "Tech", size: "1-10")
      CompanyName.create!(company: company, name: company.name, is_current: true)

      User.create!(
        company: company,
        email: "user-#{token}@example.com",
        fname: "Test",
        lname: "User",
        phone: "1111111111",
        country: "US"
      )
    end

    def create_product(name)
      product = Product.create!(name: name)
      ProductName.create!(product: product, name: name, is_current: true)
      product
    end
  end
end

exit(1) unless Csv::PlainInterestFailingTests.new.run
