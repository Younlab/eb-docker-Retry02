FROM            python:3.6.5-slim
MAINTAINER      d.sehyeon@gmail.com

RUN             apt -y update && apt -y dist-upgrade
RUN             apt -y install build-essential
RUN             apt -y install nginx supervisor

COPY            ./requirements.txt  /srv/
RUN             pip install -r /srv/requirements.txt

ENV             BUILD_MODE      production
ENV             DJANGO_SETTINGS_MODULE  config.settings.${BUILD_MODE}

COPY            .       /srv/project
# 로그파일 기록 위한 폴더 생성
RUN             mkdir /var/log/django
RUN             cp -f   /srv/project/.config/${BUILD_MODE}/nginx.conf \
                        /etc/nginx/nginx.conf   && \
                cp -f   /srv/project/.config/common/nginx_app.conf \
                        /etc/nginx/sites-available/ && \
                rm -f   /etc/nginx/sites-enabled/* && \
                ln -sf   /etc/nginx/sites-available/nginx_app.conf \
                        /etc/nginx/sites-enabled/

RUN             cp -f   /srv/project/.config/${BUILD_MODE}/supervisor_app.conf \
                        /etc/supervisor/conf.d/

EXPOSE          7000
CMD             supervisord -n