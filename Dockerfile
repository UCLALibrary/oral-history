# The actual docker build (see Dockerfile.full_build) is broken due to the end of node 14 support, so this simply updates the last successful build (Feb 2025) with the curent application codebase.

FROM uclalibrary/oral-history:81115371 AS web

COPY --chown=app:app Gemfile* $APP_HOME/
RUN /sbin/setuser app bash -l -c "bundle check || bundle install"

COPY ops/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run
RUN rm -f /etc/service/nginx/down

COPY ops/webapp.conf /etc/nginx/sites-enabled/webapp.conf
COPY ops/env.conf /etc/nginx/main.d/env.conf

COPY --chown=app:app . $APP_HOME
RUN /sbin/setuser app bash -l -c " \
    cd /home/app/webapp && \
    yarn install && \
    NODE_ENV=production DB_ADAPTER=nulldb bundle exec rake assets:precompile"
