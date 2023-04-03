FROM centos:centos8


RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Create pykmip directory
RUN mkdir -p /root/pykmip

COPY create_certificates.py /root/pykmip/
COPY run_server.py /root/pykmip/
COPY server.conf /root/pykmip/
COPY pykmip.sh /root/pykmip/
COPY rsa_create.py /root/pykmip/



RUN chmod +x /root/pykmip/pykmip.sh
RUN chmod 777 /root/pykmip/pykmip.sh

EXPOSE 5696/tcp


ENTRYPOINT ["/root/pykmip/pykmip.sh"]