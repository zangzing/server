module FriendlyId
  class TaskRunner

    def make_slugs
      validate_uses_slugs
      cond = "slugs.id IS NULL"
      options = {:limit => 100, :include => :slugs, :conditions => cond, :order => "#{klass.table_name}.id ASC"}.merge(task_options || {})
      while records = find(:all, options) do
        break if records.size == 0
        records.each do |record|
          record.save(:validate => false)
          yield(record) if block_given?
        end
        options[:conditions] = cond + " and #{klass.table_name}.created_at > '#{records.last.created_at}'"
      end
    end

  end
end
