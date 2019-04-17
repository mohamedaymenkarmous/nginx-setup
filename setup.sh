current_dir=/root

sudo apt-get update
sudo apt-get install -y net-tools git systemd python vim curl wget
sudo apt-get install -y dialog apt-utils autoconf automake build-essential libcurl4-openssl-dev libgeoip-dev liblmdb-dev libpcre++-dev libtool libxml2-dev libyajl-dev pkgconf wget zlib1g-dev libssl-dev libxslt-dev libgd-dev libgeoip-dev libaio-dev libaio1 checkinstall libperl-dev

#https://gist.github.com/virtualadrian/732e9baf9513f47a78099a051ec5bd25
#apt-get install \
#  bzip2 \
#  devscripts \
#  flex \
#  graphicsmagick-imagemagick-compat \
#  graphicsmagick-libmagick-dev-compat \
#  libass-dev \
#  libatomic-ops-dev \
#  libavcodec-dev \
#  libavdevice-dev \
#  libavfilter-dev \
#  libavformat-dev \
#  libavutil-dev \
#  libbz2-dev \
#  libcdio-cdda1 \
#  libcdio-paranoia1 \
#  libcdio13 \
#  libfaac-dev \
#  libfreetype6-dev \
#  libgeoip1 \
#  libgif-dev \
#  libgpac-dev \
#  libgsm1-dev \
#  libjack-jackd2-dev \
#  libjpeg-dev \
#  libjpeg-progs \
#  libjpeg8-dev \
#  liblmdb-dev \
#  libmp3lame-dev \
#  libncurses5-dev \
#  libopencore-amrnb-dev \
#  libopencore-amrwb-dev \
#  libpam0g-dev \
#  libpcre3 \
#  libpcre3-dev \
#  libpng12-dev \
#  libpng12-0 \
#  libpng12-dev \
#  libreadline-dev \
#  librtmp-dev \
#  libsdl1.2-dev \
#  libssl1.0.0 \
#  libswscale-dev \
#  libtheora-dev \
#  libtiff5-dev \
#  libva-dev \
#  libvdpau-dev \
#  libvorbis-dev \
#  libxslt1-dev \
#  libxslt1.1 \
#  libxvidcore-dev \
#  libxvidcore4 \
#  libyajl-dev \
#  make \
#  openssl \
#  perl \
#  pkg-config \
#  tar \
#  texi2html \
#  unzip \
#  zip \
#  zlib1g-dev 

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

cd /opt
sudo git clone https://github.com/mohamedaymenkarmous/nginx-config
[[ -d "/etc/nginx" ]] && mv /etc/nginx /etc/nginx-$(date +%s).bak
sudo cp -R nginx-config /etc/nginx
sudo mkdir /etc/nginx/sites-enabled
sudo ln -s /etc/nginx/sites-available/standard /etc/nginx/sites-enabled/standard

# Download Nginx
cd /opt
sudo wget http://nginx.org/download/nginx-1.14.2.tar.gz
sudo tar zxvf nginx-1.14.2.tar.gz

# Configure and install Nginx with the specified modules
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

sudo mkdir -p /var/lib/nginx
sudo mkdir -p /var/lib/nginx/body
sudo mkdir -p /var/lib/nginx/fastcgi

sudo make
sudo make modules
sudo make install
# Update ModSecurity dynamic module in Nginx modules directory
sudo mkdir /etc/nginx/modules
sudo cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules
# Load ModSecurity dynamic module in Nginx configuration file
sudo sed -i 's@#load_module modules/ngx_http_modsecurity_module.so@load_module modules/ngx_http_modsecurity_module.so@' /etc/nginx/nginx.conf

# Enable Nginx as a service in each reboot
sudo mv ${current_dir}/nginx.service /lib/systemd/system/nginx.service
sudo systemctl daemon-reload
sudo wget https://www.linode.com/docs/assets/660-init-deb.sh -P /opt
sudo mv /opt/660-init-deb.sh /etc/init.d/nginx
sudo chmod +x /etc/init.d/nginx
sudo /usr/sbin/update-rc.d -f nginx defaults
#sudo service nginx restart

# Enable OWASP ModSecurity rules
cd /etc/nginx/conf.d/
sudo git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
sudo cp owasp-modsecurity-crs/crs-setup.conf.example owasp-modsecurity-crs/crs-setup.conf
sudo cp owasp-modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example owasp-modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
sudo cp owasp-modsecurity-crs/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example owasp-modsecurity-crs/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf

# Enable ModSecurity main rules
sudo cp /opt/ModSecurity/modsecurity.conf-recommended /etc/nginx/conf.d/modsecurity.conf
sudo sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/conf.d/modsecurity.conf

# Update OWASP ModSecurity extra rules
sudo /etc/nginx/conf.d/owasp-modsecurity-crs/util/upgrade.py --crs

# Enable ModSecurity dynamic module in a specific site
#sudo sed -i 's/#modsecurity on/modsecurity on/' /etc/nginx/sites-enabled/standard

# Restart nginx
#sudo service nginx restart

#http://www.crop11.com.br/wiki/instalando-nginx-com-suporte-a-pagespeed-no-debian-9-stretch/
#https://www.techrepublic.com/article/how-to-install-and-enable-modsecurity-with-nginx-on-ubuntu-server/

#Upgrade php packages (>7.0)
sudo apt-get install apt-transport-https lsb-release ca-certificates
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/php.list
sudo apt-get update 

sudo apt-get install -y php-fpm
sudo mkdir -p /var/www/public/standard
echo hello | sudo tee -a /var/www/public/index.html

#apt install php-xml
#apt install php-mysql
sudo apt-get install -y mysql-server

#For Symfony
sudo apt-get -y install php-mysql php-zip php-xml php-mbstring php-mongodb php-curl php-dev php-pear
sudo pecl install mongodb
#apt install mysql-client

# Using SSL

# Stopping Nginx
sudo service nginx stop

sudo git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt --depth=1
cd /opt/letsencrypt
sudo git pull

# https://www.exratione.com/2016/06/a-simple-setup-and-installation-script-for-lets-encrypt-ssl-certificates/
# Install the dependencies.
sudo /opt/letsencrypt/certbot-auto --noninteractive --os-packages-only
 
# Set up config file.
mkdir -p /etc/letsencrypt
cat > /etc/letsencrypt/cli.ini <<EOF
# Uncomment to use the staging/testing server - avoids rate limiting.
# server = https://acme-staging.api.letsencrypt.org/directory
 
# Use a 4096 bit RSA key instead of 2048.
rsa-key-size = 4096
 
# Set email and domains.
email = contact@securinets.com
domains = ctfsecurinets.com, www.ctfsecurinets.com
 
# Text interface.
text = True
# No prompts.
non-interactive = True
# Suppress the Terms of Service agreement interaction.
agree-tos = True
 
# Use the webroot authenticator.
authenticator = standalone
#authenticator = webroot
webroot-path = /var/www/html
EOF
 
# Obtain cert.
sudo /opt/letsencrypt/certbot-auto certonly --expand
 
# Set up daily cron job.
CRON_SCRIPT="/etc/cron.daily/certbot-renew"
 
sudo cat > "${CRON_SCRIPT}" <<EOF
#!/bin/bash
#
# Renew the Let's Encrypt certificate if it is time. It won't do anything if
# not.
#
# This reads the standard /etc/letsencrypt/cli.ini.
#
 
# May or may not have HOME set, and this drops stuff into ~/.local.
export HOME="/root"
# PATH is never what you want it it to be in cron.
export PATH="\${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
 
sudo service nginx stop
sudo /opt/letsencrypt/certbot-auto --config /etc/letsencrypt/cli.ini --no-self-upgrade certonly
 
# If the cert updated, we need to update the services using it. E.g.:
if service --status-all | grep -Fq 'nginx'; then
  service nginx start
fi
EOF
chmod a+x "${CRON_SCRIPT}"

# Starting nginx
sudo service nginx start

#https://community.letsencrypt.org/t/how-to-completely-automating-certificate-renewals-on-debian/5615
#https://www.grafikart.fr/formations/serveur-linux/nginx-ssl-letsencrypt
#https://neurobin.org/docs/web/fully-automated-letsencrypt-integration-with-cpanel/
#https://www.exratione.com/2016/06/a-simple-setup-and-installation-script-for-lets-encrypt-ssl-certificates/
#https://gist.github.com/ajaegers/92318bdc81541b825c90f265f787e3c8

# Angular project
sudo mkdir -p /var/www/public/angular-project
cd /var/www/public/angular-project
git clone ANGULAR-PROJECT
sudo curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install
sudo npm install -g @angular/cli

sudo cat > /root/start-angular.sh <<EOF
#!/bin/bash
cd /var/www/public/my-app
nohup ng serve --host www.ctfsecurinets.com --proxy-config proxy.conf.json --base-href / 2>&1 >> /tmp/nohup-FE.out &
EOF
sudo chmod a+x /root/start-angular.sh
sudo ln -s /root/start-angular.sh /usr/bin/start-angular


#https://www.nginx.com/blog/setting-up-nginx-amplify-in-10-minutes/
