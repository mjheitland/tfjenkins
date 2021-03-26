#!/bin/bash

# create log directory
logdir=/var/mylogs
logfile=jenkins_log.txt
mkdir -p $logdir
echo [`date`]01 Start userdata script in `pwd` and subnet ${subnet} ... > $logdir/$logfile
chown -R ec2-user $logdir

# install Jenkins
echo [`date`]02 >> $logdir/$logfile
wget -O /etc/yum.repos.d/jenkins.repo \
  https://pkg.jenkins.io/redhat-stable/jenkins.repo
echo [`date`]03 >> $logdir/$logfile
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
echo [`date`]04 >> $logdir/$logfile
yum upgrade
echo [`date`]05 >> $logdir/$logfile
yum install -y jenkins java-1.8.0-openjdk-devel
echo [`date`]06 >> $logdir/$logfile

# configure Jenkins
echo [`date`]07 >> $logdir/$logfile
sed -i -e 's/JENKINS_ARGS=""/JENKINS_ARGS="--argumentsRealm.passwd.admin=${jenkins_admin_password} --argumentsRealm.roles.admin=admin"/g' /etc/sysconfig/jenkins
echo [`date`]08 >> $logdir/$logfile
if [ ! -f /var/lib/jenkins/config.xml ]; then
  echo [`date`]09 >> $logdir/$logfile
  echo '<?xml version="1.0" encoding="UTF-8"?><hudson><version>1.0</version><useSecurity>true</useSecurity><authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy"/><securityRealm class="hudson.security.LegacySecurityRealm"/></hudson>' > /var/lib/jenkins/config.xml
  echo [`date`]10 >> $logdir/$logfile
  chown jenkins:jenkins /var/lib/jenkins/config.xml
  echo [`date`]11 >> $logdir/$logfile
fi

# start jenkins
echo [`date`]12 >> $logdir/$logfile
systemctl daemon-reload
echo [`date`]13 >> $logdir/$logfile
systemctl start jenkins
echo [`date`]14 Jenkins status: `systemctl status jenkins | grep active` >> $logdir/$logfile
echo [`date`]15 >> $logdir/$logfile
