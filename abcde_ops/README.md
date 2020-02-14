# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby(2.4.1) and Rails(5.0.2) Installation

  * Install RVM
    curl -sSL https://get.rvm.io | bash

  * Installing Ruby
    rvm install ruby-2.4.1
    rvm use ruby-2.4.1 (making this version default) (run this command as login-shell)

  * Installing rails
    gem install rails -v 5.0.4

* Application code
    git clone deployer@testing2.myedutor.com:/home/deployer/abcde_ops.git

* System dependencies
    OS - Ubuntu (above 14.04), minimum RAM: 4GB

* Database creation
    ###Mysql Installation(5.7.18)
      * sudo apt-get install mysql-server
      (Note down user and password when prompted)

* Database initialization
    * copy the database.yml file provided to /config


* Services (job queues, cache servers, search engines, etc.)
    * whenever--cron jobs

      * whenever --update-crontab #to start the cron jobs

    * Delayed Jobs instructions

      * RAILS_ENV=production bin/delayed_job start  #to start delayed jobs
      * RAILS_ENV=production bin/delayed_job restart  #to restart delayed jobs
      * RAILS_ENV=production bin/delayed_job stop  #to stop delayed jobs

* Deployment instructions
    * copy the local_env.yml file to the /config folder
    * Restart the system
    * From the root of the application folder
    * follow the steps
        * Bundle Install
        * rake db:create db:migrate RAILS_ENV=production or bundle exec rake db:create db:migrate RAILS_ENV=production
        * whenever --update-crontab
        * RAILS_ENV=production bin/delayed_job start
        * rails s -e production -p *port_number*



