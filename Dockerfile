# Example docker run command
# docker run -p 10050:10050 -p 10051:10051 oso-rhel7-zabbix-server
# /usr/local/bin/start.sh will then start zabbix
# Default login:password to Zabbix is Admin:zabbix

#FROM oso-centos7-ops-base:latest
#FROM 172.30.27.108:5000/kwoodson/oso-centos7-ops-base
FROM oso-rhel7-ops-base:latest

# Lay down the zabbix repository
RUN yum clean metadata && \
    yum install -y openshift-ops-yum-zabbix && \
    yum clean all

# Install zabbix from zabbix repo
RUN yum install -y zabbix-server-mysql zabbix-agent zabbix-sender zabbix-agent crontabs mariadb && \
    yum -y update && \
    yum clean all

EXPOSE 10050
EXPOSE 10051

RUN chmod -R 777  /etc/passwd /root /etc/openshift_tools /var/run/zabbix /var/log/zabbix/ /etc/zabbix/


# Lay down zabbix conf
ADD zabbix/conf/zabbix_server.conf /etc/zabbix/
ADD zabbix/conf/zabbix_agentd.conf /etc/zabbix/
ADD zabbix/conf/zabbix_agent.conf /etc/zabbix/

# WORK AROUND FOR SQL SCRIPTS ARE MISSING
ADD zabbix/db_create/zdata /usr/share/doc/zabbix-server-mysql-2.4.5/create/

# DB creation
ADD zabbix/db_create/createdb.sh /root/zabbix/
ADD zabbix/db_create/create_zabbix.sql /root/zabbix/

# Add crontab for root
#ADD cronroot /var/spool/cron/root

# Add ansible playbooks
ADD ansible /root/ansible/

# Start mysqld, zabbix, and apache
ADD start.sh /usr/local/bin/
CMD /usr/local/bin/start.sh
