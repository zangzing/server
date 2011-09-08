namespace :jslint do
    desc "run googles javascript linter against javascript files"

    # to install:
    #    sudo easy_install http://closure-linter.googlecode.com/files/closure_linter-latest.tar.gz

    task :run  do
      results = %x( gjslint --unix_mode --nojsdoc -r public/javascripts/zz -r public/store/javascripts)

      results.each_line do |line|
        if line.include?('(0110) Line too long') ||
           line.include?('(0002) Missing space') ||
           line.include?('(0001) Extra space') ||
           line.include?('(0131) Single-quoted string preferred over double-quoted string.') ||
           line.include?('(0300) File does not end with new line') ||
           line.include?('(0005) Illegal tab')

          # ignore
        else
            puts line
        end

      end
    end

#    task :fixjsstyle do
#      sh "fixjsstyle --unix_mode -r public/javascripts/zz"
#    end
end
