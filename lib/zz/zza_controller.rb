module ZZ
  module ZZAController
    # give the zza worker a chance to restart if we are running
    # as a forked process because it will have been killed in that
    # case.  Later when we move to Amazon we can control the Unicorn
    # config file directly and do it only once from within there
    ZZ::ZZA.after_fork_check

    # Return a correctly initialized reference to zza tracking service
    def zza
      return @zza if @zza
      @zza = ZZ::ZZA.new
      if current_user
        @zza.user = current_user.id
        @zza.user_type = 1
      else
        @zza.user = request.cookies['_zzv_id']
        @zza.user_type = 2
      end
      @zza
    end
  end
end