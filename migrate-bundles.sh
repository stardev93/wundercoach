echo "Dropping local database..."
bundle exec rake db:drop
echo "Done!"

echo "Re-creating local database..."
bundle exec rake db:create
echo "Done!"

echo "Importing master database..."
mysql -uroot -proot wundercoach < db/dump/wundercoach_master.sql
echo "Done!"

echo "Running migrations..."
bundle exec rake db:migrate
echo "Done!"

echo "Migrating bundles..."
bundle exec rake wc:move_bundles

echo "Done!"
