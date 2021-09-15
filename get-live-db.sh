echo "Dropping local database..."
bundle exec rake db:drop
echo "Done!"

echo "Re-creating local database..."
bundle exec rake db:create
echo "Done!"

echo "Fetching & importing live database..."
bundle exec cap production db:pull
#mysql -uroot -proot wundercoach < wundercoach.sql
echo "Done!"

echo "Dumping live database content tp db/dump/wundercoach_master.sql"
mysqldump -uroot -proot wundercoach > db/dump/wundercoach_master.sql --socket=/Applications/MAMP/tmp/mysql/mysql.sock
#--column-statistics=0

echo "Running migrations..."
bundle exec rake db:migrate
echo "Done!"

#echo "Migrating bundles..."
#bundle exec rake wc:move_bundles

echo "Dumping new database content tp db/dump/wundercoach_current_branch.sql"
mysqldump -uroot -proot wundercoach > db/dump/wundercoach_current_branch.sql --socket=/Applications/MAMP/tmp/mysql/mysql.sock
# --column-statistics=0
echo "Done!"

#SELECT account_id, count(account_id) as amount FROM bundles GROUP BY account_id
#SELECT account_id, count(account_id) as amount FROM bundles, accounts WHERE accounts.id=bundles.account_id AND accounts.deleted_at IS NULL GROUP BY account_id

#SELECT account_id, count(account_id) as amount FROM events WHERE events.type='BundleEvent' GROUP BY account_id
#SELECT account_id, count(account_id) as amount FROM events, accounts WHERE accounts.id=events.account_id AND accounts.deleted_at IS NULL AND events.type='BundleEvent' GROUP BY account_id

#
# bundle exec rake db:drop
# bundle exec rake db:create
# mysql -uroot -proot wundercoach < wundercoach.sql
# bundle exec rake db:migrate
# bundle exec rake wc:move_bundles
