#!/bin/bash

gem install foreman;
bundle install;
rails cert:write;
bundle exec rails db:migrate;
bundle exec rails assets:precompile;
bundle exec rails assets:clean;
bundle exec whenever --update-crontab