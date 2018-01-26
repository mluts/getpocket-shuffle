FROM ruby:2.4-onbuild

EXPOSE 3000

CMD bash -c "bundle exec unicorn -l 0.0.0.0:3000"
