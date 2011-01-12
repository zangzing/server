namespace :services do
    desc "start nginx, redis, and resque services"

    task :run  do
        sh 'script/nginx &'
        sh 'redis-server &'
        sh 'QUEUE=* rake resque:work &'
        sh 'rake resque:schedule &'
    end
end
