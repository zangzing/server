# This class wraps code that executes in a deferred manner
# We use this class because it encapsulates the various operations
# that run deferred into one place and also handles nesting
# of the call within the same thread.  It is called via an
# around filter in the application controller as well as before
# the perform method of a resque job.  By executing deferred, code
# can gather a large set of operations and combine them into a smaller
# set.  Currently the album cache manager uses this approach to gather
# all of the invalidate operations into a smaller set because it is
# quite common to end up invalidating the same trackers during a single
# app server call.
class DeferredCompletionManager

  def self.state
    Thread.current[:deferred_completion_manager] || {}
  end

  # this is called on entry to the manager and give the code that will be doing the deferrals
  # a chance to initialize some thread local state that is used to track the operations
  # If this call nests, we will not set up state twice but will yield letting any code passed
  # run.
  #
  # This method requires a block to be passed and it yields to that block.
  #
  def self.dispatch
    begin
      cur_state = state
      if cur_state.empty?
        # need to make the thread local state
        cur_state = make_state
        Thread.current[:deferred_completion_manager] = cur_state
      end
      cur_state[:dcm_nesting] += 1
      if cur_state[:dcm_nesting] == 1
        # top level for this thread context so make state
        handlers_prepare(cur_state)
      end
      yield   # let the block run now
    ensure
      # let them finish if we are not nested
      if cur_state[:dcm_nesting] == 1
        begin
          # ok, last one out so run the deferred code
          handlers_finish(cur_state)
        ensure
          Thread.current[:deferred_completion_manager] = nil
        end
      else
        # decrement nesting level since we are not back to the top yet
        cur_state[:dcm_nesting] -= 1
      end
    end
  end

private
  # our internal state, plus defers can add their
  # state as well
  def self.make_state
    {
        :dcm_nesting => 0
    }
  end

  #todo: for simplicity we are calling the handlers directly, to make this
  # more general purpose we should instead have a registration/deregistration mechanism
  #

  # let all of the handlers that care make their thread local state here
  # this will only be called at the top level entry (i.e. if we nest it
  # will not be called)
  def self.handlers_prepare(state)
    Cache::Album::Manager.shared.deferred_prepare(state)
  end

  # called when we are about to exit our context and not nested
  # this is where the handlers should do whatever deferrals they need
  def self.handlers_finish(state)
    Cache::Album::Manager.shared.deferred_finish(state)
  end
end

