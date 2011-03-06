namespace :services do
    desc "start nginx, redis, and resque services"

    task :run  do
        sh 'script/nginx &'
        sh 'redis-server /etc/redis/redis.conf &'
        sh 'QUEUE=* rake resque:work &'
        sh 'rake resque:scheduler &'
    end
end
