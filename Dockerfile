FROM		debian:jessie
MAINTAINER	mboyer@sdf.org
RUN		apt-get update && apt-get install -y \
			gcc \
			git \
			make \
			nodejs \
			npm \
			python-pip \
			python2.7 \
			ruby2.1-dev \
			ruby2.1 && \
		ln -s /usr/bin/nodejs /usr/bin/node
RUN		pip install pygments
RUN		gem2.1 install jekyll
RUN		mkdir /jekyll /jekyll/git_scratch && \
		groupadd -r jekyll && \
		useradd -d /jekyll -g jekyll jekyll && \
		cd /jekyll && \
		git clone https://github.com/developmentseed/jekyll-hook.git && \
		cd /jekyll/jekyll-hook && npm install && \
		chown -R jekyll:jekyll /jekyll

COPY		config.json /jekyll/jekyll-hook/



RUN		mkdir /var/www /var/www/static_site
COPY		static_site/* /var/www/static_site/
VOLUME		/var/www
# Use USER to let the jekyll hook run as a non-root user
USER		jekyll
WORKDIR		/jekyll/jekyll-hook
CMD		./jekyll-hook.js
EXPOSE		8080
