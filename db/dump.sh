while true
do
    mongodump -h 127.0.0.1 --port 27017  -d hswk -o backup/$(date +%Y%m%d%H%M%S)
    mongodump -h 127.0.0.1 --port 27017  -d hswk -o backup
    sleep 1800
done
