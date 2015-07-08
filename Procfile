web: bundle exec puma -C config/puma.rb
# web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: env QUEUE=* bundle exec rake resque:work
scheduler: bundle exec rake resque:scheduler
