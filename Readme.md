
Run `cat config/database.yml` to make sure you have the correct local database settings

    rake db:drop
    rake db:create db:migrate
    rake fixtures:load_all

Start your rails server with `ruby script/server`

Visit http://localhost:3000 in a browser
