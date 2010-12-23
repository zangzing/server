namespace :nginx do
    desc "Nginx web server front end"
    task :run  do
       sh 'script/nginx'
    end
end