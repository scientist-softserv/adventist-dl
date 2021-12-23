ARG HYRAX_IMAGE_VERSION=3.0.3
FROM ghcr.io/samvera/hyku/hyku-base:$HYRAX_IMAGE_VERSION as hyku-base

USER root

RUN apk --no-cache upgrade && \
  apk --no-cache add \
    bash \
    cmake \
    ffmpeg \
    git \
    less \
    libreoffice \
    libreoffice-lang-uk \
    libxml2-dev \
    imagemagick \
    mediainfo \
    openjdk11-jre \
    perl \
    rsync \
    vim

USER app

RUN mkdir -p /app/fits && \
    cd /app/fits && \
    wget https://github.com/harvard-lts/fits/releases/download/1.5.0/fits-1.5.0.zip -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /app/fits/fits.sh
ENV PATH="${PATH}:/app/fits"
# Change the order so exif tool is better positioned and use the biggest size if more than one
# size exists in an image file (pyramidal tifs mostly)
COPY --chown=1001:101 $APP_PATH/ops/fits.xml /app/fits/xml/fits.xml
COPY --chown=1001:101 $APP_PATH/ops/exiftool_image_to_fits.xslt /app/fits/xml/exiftool/exiftool_image_to_fits.xslt
RUN ln -sf /usr/lib/libmediainfo.so.0 /app/fits/tools/mediainfo/linux/libmediainfo.so.0 && \
  ln -sf /usr/lib/libzen.so.0 /app/fits/tools/mediainfo/linux/libzen.so.0

COPY --chown=1001:101 $APP_PATH/Gemfile* /app/samvera/hyrax-webapp/
RUN bundle install --jobs "$(nproc)"

COPY --chown=1001:101 $APP_PATH /app/samvera/hyrax-webapp

ARG SETTINGS__BULKRAX__ENABLED="false"
RUN mkdir -p /app/samvera/branding && ln -s /app/samvera/branding /app/samvera/hyrax-webapp/public/branding && \
  RAILS_ENV=production SECRET_KEY_BASE=`bin/rake secret` DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rake assets:precompile

FROM hyku-base as hyku-worker
ENV MALLOC_ARENA_MAX=2
CMD ./bin/worker
