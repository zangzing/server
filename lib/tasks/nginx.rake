namespace :nginx do
    desc "Drop DB and fill it with sample test data"
    task :run  do
       sh 'script/nginx'
    end
end