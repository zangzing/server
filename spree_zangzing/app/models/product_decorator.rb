Product.class_eval do


  def pp
    puts name
    puts "#{options.count} options"
    @line = []
    @array = []
    print_types
  end

  def print_types( oti=0 )
      if oti < option_types.count
        ot = option_types[oti]
        @line << ot.name
        puts "foo#{@array.join()}={}"
        # For every option value, print all the other types
        ot.option_values.each do |ov|
          @array << "[#{ov.id}]"
          @line << ov.name
          print_types( oti+1)
        end
        @line.pop #pop last value name
        @line.pop #pop last option name
        @array.pop
      else
        #puts @line.join(' ')
        @line.pop() #pop last value name
        puts "foo#{@array.join()}="
        @array.pop()
      end
  end

  def print_variants
    puts name
    puts "#{options.count} options"
    @line = []
    @line << name
    variants.active.each do |v|
      v.option_values.each do |ov|
        @line << ov.option_type.name
        @line << ov.name
      end
      @line << "SKU: #{v.sku} #{v.price}"
      puts @line.join(' ')
      @line.pop
      v.option_values.each do |ov|
        @line.pop
        @line.pop
      end
    end


  end



end
