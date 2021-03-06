
Postrello
==========

- Postrello aims to make it possible to analyze Trello data, so you can take a look at your projects post-Trello.  The name also represents a heavier focus on making this driven by Postgresql, although it could be agnostic, but Postgres is awesome, so that's what we'll start with.

- Has an ETL process baked in that is capable of upserting data and can be run as many times for all the available trello datasets, or class-specific datasets e.g. (a board's data, card data, member data, etc...)  Warning: This is not currently optimal in performance time, it's very much a n+1 problem currently.  This is mostly ok for now given that it is the most minimum effort needed to ensure precise ETL from the Trello API to your database.  It would require a series of other processes that would open up other types of data validation issues to change this currently.  Be warned though, it could take several minutes for your first data pull depending on the size of your trello history.

- Migrations are not fun while you're still figuring out data models, so I currently manage the database schema in a sql file called schema.sql.  Even after I switch it to use migration strategies, I will use the :sql format, rather than :ruby format for schema dumps and loads, since :ruby dumps can't handle triggers/functions/any of the actually awesome stuff in postgres.

````
rake db:create
psql -d postrello_development -f schema.sql
rake admin:add_user[username,password]
rake trello:organization:upsert[organization_name]
````


