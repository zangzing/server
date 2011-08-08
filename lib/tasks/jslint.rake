namespace :jslint do
    desc "run googles javascript linter against javascript files"

    # to install:
    #    sudo easy_install http://closure-linter.googlecode.com/files/closure_linter-latest.tar.gz

    task :gjslint  do
      sh "gjslint --unix_mode -r public/javascripts/zz"
    end

#    task :fixjsstyle do
#      sh "fixjsstyle --unix_mode -r public/javascripts/zz"
#    end
end
