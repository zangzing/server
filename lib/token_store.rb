
class TokenStore

    def initialize(service_name)
      @service_name = service_name
    end

    def get_token(id)
      token_record = ActiveRecord::Base.connection.select_one("SELECT * FROM `identities` WHERE `user_id`=#{id} AND `identity_source`='#{@service_name}'")
      token_record['credentials'] rescue nil
    end

    def delete_token(id)
      token_record = ActiveRecord::Base.connection.select_one("SELECT * FROM `identities` WHERE `user_id`=#{id} AND `identity_source`='#{@service_name}'")
      if token_record
        ActiveRecord::Base.connection.execute "UPDATE `identities` SET `credentials` = NULL, `updated_at` = NOW() WHERE `id`=#{token_record['id']}"
      end
    end

    def store_token(value, id)
      token_record = ActiveRecord::Base.connection.select_one("SELECT * FROM `identities` WHERE `user_id`=#{id} AND `identity_source`='#{@service_name}'")
      if token_record
        ActiveRecord::Base.connection.execute "UPDATE `identities` SET `credentials` = '#{value}', `updated_at` = NOW() WHERE `id`=#{token_record['id']}"
      else
        ActiveRecord::Base.connection.execute "INSERT into `identities` SET `user_id` = #{id}, `identity_source` = '#{@service_name}', `credentials` = '#{value}', `created_at` = NOW(), `updated_at` = NOW()"
      end
    end

end
