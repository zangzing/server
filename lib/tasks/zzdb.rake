# overrides standard db:migrate, etc to include sub tasks
# this lets us set up rails shell projects that handle data
# migration and config when we need to work with other
# databases such as the cache database
namespace :db do
    desc "override db tasks by calling sub tasks"

    # run a task in all of the sub task dirs
    def run_sub_task(task)
      sub_task_dirs = [
          "/sub_migrates/cache_builder"
      ]

      sub_task_dirs.each do |sub_task_dir|
        d = Dir.pwd
        sub = sub_task_dir
        Dir.chdir(d + sub)
        system "rake #{task}"
        Dir.chdir(d)
      end
    end

    Rake::Task["migrate"].enhance do
      run_sub_task("db:migrate")
    end

    Rake::Task["create"].enhance do
      run_sub_task("db:create")
    end

    Rake::Task["drop"].enhance do
      run_sub_task("db:drop")
    end

    Rake::Task["seed"].enhance do
      run_sub_task("db:seed")
    end
end
