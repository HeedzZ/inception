FROM debian:bookworm

RUN apt update && apt upgrade && apt install -y nginx

RUN apt-get install openssl -y

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/inception.key -out /etc/nginx/ssl/inception.crt -subj "/CN=ymostows.42.fr"

COPY default /etc/nginx/sites-available/.

CMD ["nginx", "-g", "daemon off;"]