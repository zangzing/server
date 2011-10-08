require 'spec_helper'
require 'factory_girl'


describe Order do

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  describe "Product Catalog" do
    it "should be loaded with a product named 'Prints'" do
      Product.find_by_name('Prints').should_not be nil
    end
    it "should have at least one product not named 'Prints' with variants" do
      ps = Product.where("products.name != 'Prints'")
      ps.count.should be > 0
      has_variants = false
      ps.each{ |p| has_variants = true if p.variants.count > 0}
      has_variants.should be true
    end
  end

  describe "#add_variant" do
    before(:each) do
      #Create an order and add prints and non prints line items
      @photo = Factory.create(:photo)

      @order = Order.create
      variants = Product.find_by_name('Prints').variants
      @print_variant = variants.detect{ |variant| variant.print? }
      @not_print_variant = variants.detect{ |variant| !variant.print? }
    end

    it "should create a new line item for a new variant/photo combination" do
      @order.line_items.count.should be 0
      @order.add_variant( @not_print_variant,  @photo, 1 )
      @order.line_items.count.should be 1
      @order.add_variant( @print_variant,  @photo, 1 )
      @order.line_items.count.should be 2
    end

    it "should NOT create a new line item for an existing nonprint-variant/photo combination" do
      first_item = @order.add_variant( @not_print_variant,  @photo, 1 )
      first_item.quantity.should be 1
      @order.line_items.count.should be 1
      second_item = @order.add_variant( @not_print_variant,  @photo, 1 )
      second_item.should be first_item
      first_item.quantity.should be 2
      @order.line_items.count.should be 1
    end

    it "should create a new line item for an existing print-variant/photo combination" do
      first_item = @order.add_variant( @print_variant,  @photo, 1 )
      first_item.quantity.should be 1
      @order.line_items.count.should be 1
      second_item =@order.add_variant( @print_variant,  @photo, 1 )
      second_item.should_not be first_item
      second_item.quantity.should be 1
      first_item.quantity.should be 1
      @order.line_items.count.should be 2
    end

    after(:each) do
      @photo.user.destroy rescue nil
      @photo.destroy rescue nil
      @order.destroy rescue nil
    end
  end

  describe "Prints Roll Up" do
    before(:each) do
      #Create an order and add prints and non prints line items
      @photo = Factory.create(:photo)
      @photo2 = Factory.create(:photo)

      @order = Order.create

      #PRINTS
      prints = Product.find_by_name('Prints')
      printset_variants    = prints.variants.where("price < ?", Spree::Config[:printset_threshold])
      notprintset_variants = prints.variants.where("price >= ?", Spree::Config[:printset_threshold])
      @order.add_variant( printset_variants.first,  @photo, 1 )
      @order.add_variant( printset_variants.first,  @photo2, 1 )
      @order.add_variant( printset_variants.third,  @photo, 1 )
      @order.add_variant( printset_variants.third,  @photo2, 1 )
      @order.add_variant( printset_variants.fifth,  @photo, 1 )

      #NOT_PRINTS
      nop = Product.where("products.name != 'Prints'").first
      @order.add_variant( nop.variants.first,  @photo, rand(10) )
      @order.add_variant( nop.variants.first,  @photo2, rand(10) )
      @order.add_variant( nop.variants.third,  @photo, rand(10) )
      @order.add_variant( notprintset_variants.first,  @photo2, rand(10) )
      @order.add_variant( notprintset_variants.first,  @photo, rand(10) )
      @order.add_variant( notprintset_variants.second,  @photo2, rand(10) )
      @order.add_variant( notprintset_variants.second,  @photo, rand(10) )


      # The order has
      # - 5 printset line items using 3 variants
      # - 7 no prints line items using 4 variants
    end

    it "should return all non-print line-items" do
      @order.line_items.not_prints.count.should be 7
    end

    it "should return all print line-items" do
      @order.line_items.prints.count.should be 5
    end
    it "should return prints line_items grouped by variants" do
      @order.line_items.prints.group_by_variant.length.should be 3
      @order.line_items.not_prints.group_by_variant.length.should be 4
    end

    it "order.printset_quantity should change the quantity of all printset line items" do
      @order.line_items.prints.each { |li| li.quantity.should be 1 }
      @order.printset_quantity = 5
      @order.line_items.prints.each { |li| li.quantity.should be 5 }
      @order.printset_quantity.should be 5
    end

    after(:each) do
      # if you change this to use before and after(:all), rspec does not like to
      # pass instance vars such as @photo but if they are defined as class vars @@photo
      # they do exist.  Anyways for now I am just using :each to avoid the problem.  This
      # seems like an rspec bug.
      # Also FYI, if you use :all you must clean up on your own because those objects get
      # inserted into the database and are not cleaned up by transactional fixtures since
      # they are done outside of a transaction.
      #
      # The stuff below isn't strictly necessary if we run as :each rather than :all
      @photo.user.destroy rescue nil
      @photo.destroy rescue nil
      @photo2.user.destroy rescue nil
      @photo2.destroy rescue nil
      @order.destroy rescue nil
    end
  end
end