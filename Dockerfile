FROM ruby:2.4-onbuild

EXPOSE 3000

CMD bash -c "rackup -o 0.0.0.0 -p 3000"
