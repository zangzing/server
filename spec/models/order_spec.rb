require 'spec_helper'
require 'factory_girl'


describe Order do

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  describe "Line Item validation" do
    before(:each) do
      @order = Order.create
      variants = Product.find_by_name('Prints').variants
      @print_variant = variants.detect{ |variant| variant.print? }
    end

    it 'should verify that all line items have photos' do
      photo = Factory.create(:photo)
      photo.mark_ready
      photo.save
      @order.add_variant( @print_variant,  photo, 1 )
      @order.line_items.count.should be 1
      @order.all_photos_valid?.should be true
    end

    it 'should fail to verify a line item with a missing photo' do
      photo = Factory.create(:photo)
      @order.add_variant( @print_variant,  photo, 1 )
      @order.line_items.count.should be 1
      line = @order.line_items[0]
      line.photo = nil
      line.save
      @order.all_photos_valid?.should be false
    end
  end

  describe "Product Catalog" do
    it "should be loaded with a product named 'Prints' with ID #{LineItem::PRINTS_PRODUCT_ID}" do
      p = Product.find_by_name('Prints')
      p.should_not be nil
      p.id.should be == LineItem::PRINTS_PRODUCT_ID
    end
    it "should be loaded with an Option Value named 'No Frame' with ID #{LineItem::NO_FRAME_VALUE_ID}" do
          ov = OptionValue.find_by_name('No Frame')
          ov.should_not be nil
          ov.id.should be == LineItem::NO_FRAME_VALUE_ID
    end
    it "should be loaded with an Option Value named 'FRAMED' with ID #{LineItem::FRAMED_VALUE_ID}" do
          ov = OptionValue.find_by_name('FRAMED')
          ov.should_not be nil
          ov.id.should be == LineItem::FRAMED_VALUE_ID
    end

    it "should have at least one product not named 'Prints' with variants" do
      ps = Product.where("products.name != 'Prints'")
      ps.count.should be > 0
      has_variants = false
      ps.each{ |p| has_variants = true if p.variants.count > 0}
      has_variants.should be true
    end
    it "should have an packing_type taxonomy with an index_print taxon" do
      taxonomy = Taxonomy.find_by_name('packing_type')
      taxonomy.should_not be nil
      taxon_names = taxonomy.taxons.map{ |taxon|  taxon.name }
      included = taxon_names.include? "index_print"
      included.should_not be nil
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
      printset_variants    = prints.variants.select{ |v| v.print? }
      notprintset_variants = prints.variants.select{ |v| !v.print? }
      @order.add_variant( printset_variants.first,  @photo, 1 )
      @order.add_variant( printset_variants.first,  @photo2, 1 )
      @order.add_variant( printset_variants.third,  @photo, 1 )
      @order.add_variant( printset_variants.third,  @photo2, 1 )
      @order.add_variant( printset_variants.fifth,  @photo, 1 )
      @order.add_marketing_insert


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
      # - 3 printset line items using 3 variants
      # - 7 no prints line items using 4 variants
      # - 1 Marketing print line item (hidden)
    end

    it 'there should be line items' do
      @order.line_items.count.should be 13
    end

    it "should return all non-print line-items" do
      @order.line_items.not_prints.length.should be 7
    end

    it "should return all print line-items" do
      @order.line_items.prints.count.should be 5
    end
    it "should return prints line_items grouped by variants" do
      @order.line_items.prints.group_by_variant.length.should be 3
    end

    it "order.printset_quantity should change the quantity of all printset line items" do
      #iterate the variants
      variant = @order.line_items.prints.group_by_variant.first
      @order.line_items.find_all_by_variant_id( variant.id ).each { |li| li.quantity.should be 1 }
      @order.printset_quantity = { variant.id => 5} 
      @order.line_items.find_all_by_variant_id( variant.id ).each { |li| li.quantity.should be 5 }
    end

    it "#cart_count should return correct cart count" do
      @order.cart_count.should be 10
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

  describe "Finalize" do
    before(:each) do
      @order = Factory.create(:order)
      @photo = Factory.create(:photo)

    end
    
    it 'should add a line item for a marketing print if order contains IndexPrint products' do
      index_print_product = Product.taxons_name_eq('index_print').first
      index_print_variant = index_print_product.variants.first
      @order.line_items.count.should be 0
      @order.add_variant( index_print_variant,  @photo, 1 )
      @order.line_items.count.should be 1
      @order.finalize!
      @order.line_items.count.should be 2
      visible_line_items = @order.line_items.prints.length + @order.line_items.not_prints.length
      visible_line_items.should be 1
    end

    it 'should NOT add a line_item for marketing print if the order does not contain IndexPrint products' do
      work_order_product = Product.taxons_name_eq('work_order').first
      work_order_variant = work_order_product.variants.first
      @order.line_items.count.should be 0
      @order.add_variant( work_order_variant,  @photo, 1 )
      @order.line_items.count.should be 1
      @order.finalize!
      @order.line_items.count.should be 1
      visible_line_items = @order.line_items.prints.length + @order.line_items.not_prints.length
      visible_line_items.should be 1
    end

    it 'should send order confirmed email' do
      resque_jobs(:except => [ZZ::Async::MailingListSync]) do

        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.deliveries = []
        @order.finalize!
        ActionMailer::Base.deliveries.count.should == 1
        ActionMailer::Base.deliveries[0].header['X-SMTPAPI'].value.should include "email.store.orderconfirmed"
      end
    end
  end


end