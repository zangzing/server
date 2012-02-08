module Cache
  module Album

    # this flavor of the invalidator does not do invalidation
    # on the .invalidate method.  Instead it adds the invalidate_now
    # method which does the actual invalidation.
    # This allows us to use it when called inside the context
    # of a deferred completion and collect all the operations
    # along the way
    class DeferredInvalidator < Invalidator
      # override the normal invalidate behavior to do nothing
      def invalidate
      end
    end
  end
end


