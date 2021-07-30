FROM httpd:2.4

ENV INSTALL=
ENV SERVER=
ENV BASE=

COPY ${INSTALL} deb64.tar.gz
RUN tar -xzf deb64.tar.gz -C / \
  && apt-get -qq update \
  && dpkg -i /*.deb \
  && rm /*.deb 

COPY httpd.conf /usr/local/apache2/conf/httpd.conf
RUN   sed -i'' -e "s|BASE1C|${BASE}|g" /usr/local/apache2/conf/httpd.conf

COPY default.vrd /usr/local/apache2/htdocs/${BASE}/default.vrd
RUN   sed -i'' -e "s|SERVER1C|${SERVER}|g" /usr/local/apache2/htdocs/${BASE}/default.vrd
RUN   sed -i'' -e "s|BASE1C|${BASE}|g" /usr/local/apache2/htdocs/${BASE}/default.vrd
