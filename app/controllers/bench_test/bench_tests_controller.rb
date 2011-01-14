# base class for bench test controllers
class BenchTest::BenchTestsController < ApplicationController
  layout "bench_tests"

  def showtests
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def mark_as_starting test
    test.result_message = "Test Starting."
    test.save!
  end
end