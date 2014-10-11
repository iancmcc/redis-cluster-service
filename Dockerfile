FROM       ubuntu:trusty
MAINTAINER Ian McCracken <ian.mccracken@gmail.com>

RUN groupadd -r redis && useradd -r -g redis redis
RUN apt-get update \
    && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*


ENV REDIS_VERSION 3.0.0-rc1
ENV REDIS_DOWNLOAD_URL https://github.com/antirez/redis/archive/3.0.0-rc1.tar.gz

RUN BUILD_DEPS="gcc libc6-dev make ruby"; \
    set -x; \
    apt-get update && apt-get install -y $BUILD_DEPS --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /usr/src/redis \
    && curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    && make -C /usr/src/redis \
    && make -C /usr/src/redis install \
    && ln -s redis-server "$(dirname "$(which redis-server)")/redis-sentinel" \
    && cp /usr/src/redis/src/redis-trib.rb /usr/local/bin \
    && chmod a+x /usr/local/bin/redis-trib.rb \
    && rm -r /usr/src/redis \
    && apt-get purge -y $BUILD_DEPS \
    && apt-get autoremove -y

RUN mkdir /data && chown redis:redis /data
WORKDIR /data
EXPOSE 6379
