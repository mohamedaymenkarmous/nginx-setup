sudo apt-get update
sudo apt-get install git
sudo apt-get install -y apt-utils autoconf automake build-essential git libcurl4-openssl-dev libgeoip-dev liblmdb-dev libpcre++-dev libtool libxml2-dev libyajl-dev pkgconf wget zlib1g-dev libssl-dev libxslt-dev libgd-dev libgeoip-dev libaio-dev libaio1 checkinstall libperl-dev

#https://gist.github.com/virtualadrian/732e9baf9513f47a78099a051ec5bd25
apt-get install \
  bzip2 \
  devscripts \
  flex \
  graphicsmagick-imagemagick-compat \
  graphicsmagick-libmagick-dev-compat \
  libass-dev \
  libatomic-ops-dev \
  libavcodec-dev \
  libavdevice-dev \
  libavfilter-dev \
  libavformat-dev \
  libavutil-dev \
  libbz2-dev \
  libcdio-cdda1 \
  libcdio-paranoia1 \
  libcdio13 \
  libfaac-dev \
  libfreetype6-dev \
  libgeoip1 \
  libgif-dev \
  libgpac-dev \
  libgsm1-dev \
  libjack-jackd2-dev \
  libjpeg-dev \
  libjpeg-progs \
  libjpeg8-dev \
  liblmdb-dev \
  libmp3lame-dev \
  libncurses5-dev \
  libopencore-amrnb-dev \
  libopencore-amrwb-dev \
  libpam0g-dev \
  libpcre3 \
  libpcre3-dev \
  libpng12-dev \
  libpng12-0 \
  libpng12-dev \
  libreadline-dev \
  librtmp-dev \
  libsdl1.2-dev \
  libssl1.0.0 \
  libswscale-dev \
  libtheora-dev \
  libtiff5-dev \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxslt1-dev \
  libxslt1.1 \
  libxvidcore-dev \
  libxvidcore4 \
  libyajl-dev \
  make \
  openssl \
  perl \
  pkg-config \
  tar \
  texi2html \
  unzip \
  zip \
  zlib1g-dev 

cd /opt
#https://www.nginx.com/blog/compiling-and-installing-modsecurity-for-open-source-nginx/
sudo git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
cd ModSecurity
sudo git submodule init
sudo git submodule update
sudo ./build.sh
sudo ./configure
sudo make
sudo make install
cd /opt
sudo git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git
sudo wget http://nginx.org/download/nginx-1.12.2.tar.gz
sudo tar zxvf nginx-1.12.2.tar.gz
cd nginx-[0-9]*[^a-z]
sudo ./configure \
  --add-dynamic-module=/opt/ModSecurity-nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --group=www-data \
  --http-client-body-temp-path=/var/lib/nginx/body \
  --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
  --http-log-path=/var/log/nginx/access.log \
  --http-proxy-temp-path=/var/lib/nginx/proxy \
  --http-scgi-temp-path=/var/lib/nginx/scgi \
  --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
  --lock-path=/var/lock/nginx.lock \
  --pid-path=/run/nginx.pid \
  --prefix=/usr/share/nginx \
  --sbin-path=/usr/sbin/nginx \
  --user=www-data \
  --with-debug \
  --with-file-aio \
  --with-http_addition_module \
  --with-http_auth_request_module \
  --with-http_dav_module \
  --with-http_flv_module \
  --with-http_geoip_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_image_filter_module \
  --with-http_mp4_module \
  --with-http_perl_module \
  --with-http_random_index_module \
  --with-http_realip_module \
  --with-http_secure_link_module \
  --with-http_slice_module \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-http_sub_module \
  --with-http_v2_module \
  --with-http_xslt_module \
  --with-mail \
  --with-mail_ssl_module \
  --with-pcre-jit \
  --with-poll_module  \
  --with-select_module \
  --with-stream \
  --with-stream_ssl_module \
  --with-threads \
  --with-compat

sudo make
sudo make modules
sudo make install
sudo mkdir /etc/nginx/modules
sudo cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules

#http://www.crop11.com.br/wiki/instalando-nginx-com-suporte-a-pagespeed-no-debian-9-stretch/
#https://www.techrepublic.com/article/how-to-install-and-enable-modsecurity-with-nginx-on-ubuntu-server/

apt install php-fpm
mkdir -p /var/www/public
echo hello > /var/www/public/index.html

apt install php-xml
apt install php-mysql
apt install mysql-server
apt install mysql
apt install mysql-client
