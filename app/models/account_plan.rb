class AccountPlan


  def initialize(storage_used, bonus_storage)
    plan_storage_used = storage_used - bonus_storage
    @bonus_storage = bonus_storage

    if plan_storage_used <= 2 * 1024
      @name = 'ZangZing Free'
      @plan_storage = 2 * 1024
      @description = '2GB or up to 10GB if you invite friends. FREE!'

    elsif plan_storage_used <= 25 * 1024
      @name = 'ZangZing 25'
      @plan_storage = 25 * 1024
      @description = '25GB or up to 33GB if you invite friends. $5/mo or $50/year.'

    elsif plan_storage_used <= 50 * 1024
      @name = 'ZangZing 50'
      @plan_storage = 50 * 1024
      @description = '50GB or up to 58GB if you invite friends. $10/mo or $100/year.'

    else
      @name = 'ZangZing 100'
      @plan_storage = 100 * 1024
      @description = '100GB or up to 108GB if you invite friends. $20/mo or $200/year.'

    end


  end

  def name
    @name
  end

  def description
    @description
  end

  def total_storage
    @plan_storage + @bonus_storage
  end

end