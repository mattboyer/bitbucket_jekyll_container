FROM		debian:jessie
MAINTAINER	mboyer@sdf.org
RUN		apt-get update && apt-get install -y \
			git \
			nodejs \
			python2.7 python2.7-dev python-pip \
			ruby2.1 ruby2.1-dev

# Install the BitBucket webhook as well as GUnicorn
RUN		pip2 install --upgrade pip && pip2 install \
			bitbucket-jekyll-hook \
			gunicorn \
			pygments

# Install Jekyll
RUN		gem2.1 install jekyll

# Set up a user for the webhook service
RUN		mkdir /jekyll /jekyll/.ssh && \
		groupadd -r jekyll && \
		useradd -d /jekyll -g jekyll jekyll

COPY		deployment_key/id* /jekyll/.ssh/

COPY		bitbucket_host_key /jekyll/.ssh/known_hosts
COPY		ssh_config /jekyll/.ssh/config
COPY		gunicorn_config.py /jekyll/
RUN		chown -R jekyll:jekyll /jekyll && chmod 0700 /jekyll/.ssh

# Set up a directory for the site
RUN		mkdir /var/www /var/www/static_site
COPY		static_site/* /var/www/static_site/
RUN		chown -R jekyll:jekyll /var/www

VOLUME		/var/www
USER		jekyll
WORKDIR		/jekyll
CMD		env PUBLISH_DEST=/var/www/static_site PUBLISH_BRANCH=live gunicorn -c gunicorn_config.py BB_jekyll_hook.jekyll_hook:app
EXPOSE		8000
