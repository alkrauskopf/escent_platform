
To run this on OS X, you'll need to install the following:

    brew install gs
    brew install mysql

Run `cat config/database.yml` to make sure you have the correct local database settings

    script/reset_db
    
OR

    rake db:drop
    rake db:create db:migrate
    rake fixtures:load_all

Start your rails server with `ruby script/server`

Visit http://localhost:3000 in a browser
