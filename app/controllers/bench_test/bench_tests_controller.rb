# base class for bench test controllers
class BenchTest::BenchTestsController < ApplicationController
  layout "bench_tests"

  def showtests
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def mark_as_starting test
    iterations = test.iterations
    if (iterations.nil? || iterations == 0)
      test.result_message = "Less than 1 iteration was given, test not run."
      test.save!
    else
      test.result_message = "Test Starting."
      test.save!

      # now kick off the work
      create_work test
    end
  end
end