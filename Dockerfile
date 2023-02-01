FROM ghcr.io/scientist-softserv/dev-ops/samvera:f71b284f as hyku-base

COPY --chown=1001:101 $APP_PATH/Gemfile* /app/samvera/hyrax-webapp/
RUN bundle install --jobs "$(nproc)"
COPY --chown=1001:101 $APP_PATH/bin/db-migrate-seed.sh /app/samvera/
COPY --chown=1001:101 $APP_PATH /app/samvera/hyrax-webapp

ARG SETTINGS__BULKRAX__ENABLED="true"
RUN mkdir -p /app/samvera/branding && ln -s /app/samvera/branding /app/samvera/hyrax-webapp/public/branding && \
  yarn install && \
  RAILS_ENV=production SECRET_KEY_BASE=`bin/rake secret` DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rake assets:precompile

FROM hyku-base as hyku-worker
ENV MALLOC_ARENA_MAX=2
CMD ./bin/worker
