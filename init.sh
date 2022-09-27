#!/bin/sh
mysql -u root -p < db/db.sql
go build main.go 
sudo ss -lptn 'sport = :5000'
kill $(pgrep shab)
./shab > /dev/null 2>&1 & 
echo "runnin on prccedd id :" + $(pgrep main)
