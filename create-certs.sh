openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout frontend/certs/nginx-selfsigned.key -out frontend/certs/nginx-selfsigned.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=localhost"
