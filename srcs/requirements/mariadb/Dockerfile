FROM debian:bookworm

RUN apt update && apt upgrade -y && apt install -y mariadb-server mariadb-client

COPY 50-server.cnf /etc/mysql/mariadb.conf.d/.
COPY script.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/script.sh

CMD ["script.sh"]
