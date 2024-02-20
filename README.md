# Installation
This web application uses Ruby 3.2.3. If you are using rbenv for managing different Ruby installs, the `.ruby-version` file in the root will trigger rbenv to use the correct Ruby version.

We are using Redis for caching. Please install Redis with `brew install redis` then run the Redis server with `redis-server --save "" --appendonly no`.

Movie search is a Sinatra application. It will use Puma for running the application server. Install Puma with `gem install puma`.

Add your API key for TheMovieDatabase to the `.env` file under `TMDB_API_KEY`. Feel free to adjust `REDIS_URL` and/or `REDIS_DB_NUMBER` to avoid any clashes with your existing Redis databases.

We use Bundler for managing dependencies. This is installed along with Ruby. Download the dependencies by running `bundle`.

Run the application with `ruby movies.rb` and access it on `http://localhost:4567`.
