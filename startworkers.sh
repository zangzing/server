#!/bin/sh
#
# this script is used to start all the extra worker processes 
# that the server needs to operate fully
#
# 
if [ -z "${IMAGEMAGICK_PATH}" ]; then echo IMAGEMAGICK_PATH is not set; exit; fi
echo 'Starting nginx'
script/nginx &

echo 'Starting redis-server'
sudo redis-server /etc/redis/redis.conf &

echo 'Starting resque:work'
QUEUE=* rake resque:work &

# keep script blocked for last task
echo 'Starting resque:scheduler'
rake resque:scheduler

exit;




