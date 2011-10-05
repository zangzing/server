

@variant_options_hash = Hash[grouped_option_values.map{ |type, values|
     [type.id.inspect, Hash[values.map{ |value|
       [value.id.inspect, Hash[variants.includes(:option_values).select{ |variant|
         variant.option_values.select{ |val|
           val.id == value.id && val.option_type_id == type.id
         }.length == 1 }.map{ |v| [ v.id, { :id => v.id, :count => v.count_on_hand, :price => number_to_currency(v.price) } ] }]
       ]
     }]]
   }]




h =    Hash[canvas.option_types.map{|i| i.option_values }.flatten.uniq.group_by(&:option_type).map{ |type, values|
        [type.id.inspect, Hash[values.map{ |value|
          [value.id.inspect, Hash[canvas.variants.includes(:option_values).select{ |variant|
            variant.option_values.select{ |val|
              val.id == value.id && val.option_type_id == type.id
            }.length == 1 }.map{ |v| [ v.id, { :id => v.id, :count => v.count_on_hand, :price =>v.price } ] }]
          ]
        }]]
      }]