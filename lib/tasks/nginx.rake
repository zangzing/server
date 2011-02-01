namespace :nginx do
    desc "Nginx web server front end"
    task :run  do
       sh 'mkdir /tmp/fast_uploads'   unless File.directory? '/tmp/fast_uploads'
       sh 'mkdir /tmp/fast_uploads/0' unless File.directory? '/tmp/fast_uploads/0'
       sh 'mkdir /tmp/fast_uploads/1' unless File.directory? '/tmp/fast_uploads/1'
       sh 'mkdir /tmp/fast_uploads/2' unless File.directory? '/tmp/fast_uploads/2'
       sh 'mkdir /tmp/fast_uploads/3' unless File.directory? '/tmp/fast_uploads/3'
       sh 'mkdir /tmp/fast_uploads/4' unless File.directory? '/tmp/fast_uploads/4'
       sh 'mkdir /tmp/fast_uploads/5' unless File.directory? '/tmp/fast_uploads/5'
       sh 'mkdir /tmp/fast_uploads/6' unless File.directory? '/tmp/fast_uploads/6'
       sh 'mkdir /tmp/fast_uploads/7' unless File.directory? '/tmp/fast_uploads/7'
       sh 'mkdir /tmp/fast_uploads/8' unless File.directory? '/tmp/fast_uploads/8'
       sh 'mkdir /tmp/fast_uploads/9' unless File.directory? '/tmp/fast_uploads/9'
       sh 'script/nginx'
    end
end