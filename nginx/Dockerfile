FROM nginx

COPY reverse.conf /etc/nginx/conf.d/default.conf
COPY local.example.dev+2-key.pem /etc/nginx/ssl/server.key
COPY local.example.dev+2.pem /etc/nginx/ssl/server.crt

CMD ["nginx", "-g", "daemon off;"]
