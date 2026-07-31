FROM nginx:1.28-alpine

COPY app/index.html /usr/share/nginx/html/index.html

EXPOSE 80