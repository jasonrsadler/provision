user www-data;
worker_processes 2;
error_log /var/log/nginx/error.log;
worker_rlimit_nofile 8192;



events {
  worker_connections 4096;
}

http {
server {
  listen 80;
  listen [::]:80;
  server_name 127.0.0.1;
  return 301 https://$server_name$request_uri;
}

server {
   listen 443 ssl http2 default_server;
   listen [::]:443 ssl http2 default_server;
   ssl_certificate /etc/ssl/self-signed.crt;
   ssl_certificate_key /etc/ssl/self-signed.key;
   error_page 401 403 404 /404.html;
   location / {
      allow 127.0.0.1/24;
      deny all;
   }
}

  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  keepalive_timeout 65;
  types_hash_max_size 2048;
  server_tokens off;

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;

  add_header X-Frame-Options DENY;
  add_header X-Content-Type-Options nosniff;

  log_format timed_combined '$remote_addr - $remote_user [$time_local] '
     '"$request" $status $body_bytes_sent '
     '"$http_referer" "$http_user_agent" '
     '$request_time $upstream_response_time $pipe';

  access_log /var/log/nginx/timed_access.log timed_combined;
  error_log /var/log/nginx/error.log;

  gzip on;
  gzip_disable "msie6";
  gzip_vary on;
  gzip_proxied any;
  gzip_comp_level 6;
  gzip_buffers 16 8k;
  gzip_http_version 1.1;
  gzip_min_length 256;
  gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
  
  include /etc/nginx/conf.d/*.conf;
  include /etc/nginx/sites-enabled/*;
}
