# utility class to perform hash conversions
# currently just does xml to hash
class HashConverter

  #
  # convert the xml node to a hash derived from https://gist.github.com/335286
  #
  # set the separate_attributes flag if you want the attributes to be grouped
  # under :attributes, otherwise they will be treated as direct keys
  #
  def self.from_xml(node, separate_attributes = false, auto_type = false)
    begin
      node = node.root unless node.element?
      return { node.name.to_sym => xml_node_to_hash(node, separate_attributes, auto_type)}
    rescue Exception => e
      raise ArgumentError, "Unable to parse XML into hash: #{e.message}"
    end
  end


  def self.xml_node_to_hash(node, separate_attributes, auto_type)
    # If we are at the root of the document, start the hash
    if node.element?
      result_hash = {}
      if node.attributes != {}
        result_hash[:attributes] = {} if separate_attributes
        node.attributes.keys.each do |key|
          if separate_attributes
            result_hash[:attributes][node.attributes[key].name.to_sym] = convert(node.attributes[key].value, auto_type)
          else
            result_hash[node.attributes[key].name.to_sym] = convert(node.attributes[key].value, auto_type)
          end
        end
      end
      if node.children.size > 0
        node.children.each do |child|
          result = xml_node_to_hash(child, separate_attributes, auto_type)

          if child.name == "text"
            unless child.next_sibling || child.previous_sibling
              return convert(result, auto_type)
            end
          elsif result_hash[child.name.to_sym]
            if result_hash[child.name.to_sym].is_a?(Object::Array)
              result_hash[child.name.to_sym] << convert(result, auto_type)
            else
              result_hash[child.name.to_sym] = [result_hash[child.name.to_sym]] << convert(result, auto_type)
            end
          else
            result_hash[child.name.to_sym] = convert(result, auto_type)
          end
        end

        return result_hash
      else
        return result_hash
      end
    else
      return convert(node.content.to_s, auto_type)
    end
  end

  # convert, if auto_type is set we
  # will try to determine type and convert
  # for Integer and Float
  def self.convert(data, auto_type)
    return data if data.is_a?(String) == false || auto_type == false

    # see if it's an int
    num = Integer(data) rescue nil
    if num.nil?
      # try to see if a float
      num = Float(data) rescue nil
    end
    num.nil? ? data : num
  end

end