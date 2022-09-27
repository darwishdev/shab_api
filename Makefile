dball:
	mysql -u root -h 127.0.0.1  --password=asd@asd@ < db/db.sql && \
	mysql -u root -h 127.0.0.1  --password=asd@asd@ < db/seed.sql && \
	mysql -u root -h 127.0.0.1  --password=asd@asd@ < db/proc.sql 

migrate:
	mysql -u root -h 127.0.0.1  --password=asd@asd@ < db/db.sql 



migpro:
	mysql -u root -h 127.0.0.1  --password=asd@asd@ < db/db.sql && \
	mysql -u root -h 127.0.0.1  --password=asd@asd@ < db/proc.sql && \
	mysql -u root -h 127.0.0.1  --password=asd@asd@ < db/merge.sql 
exec:
	mysql -u root -h 127.0.0.1  --password=asd@asd@ < db/exec.sql 

proc:
	mysql -u root -h 127.0.0.1  --password=asd@asd@ < db/proc.sql  && \
	mysql -u root -h 127.0.0.1  --password=asd@asd@ < db/merge.sql 


dump:
	mysqldump -u root -p alshab_staging2 > db/backup.sql
