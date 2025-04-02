FROM nginx:1.27.4


ADD reverse.conf /etc/nginx/conf.d/default.conf

# RUN envsubst '$NGINX_CERT $NGINX_KEY' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && \
# rm /etc/nginx/conf.d/default.conf.template

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
