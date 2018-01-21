#! /bin/bash
echo "##############################################"
echo "#                                            #"
echo "#   Install script for JIRA - START          #"
echo "#                                            #"
echo "##############################################"
echo ""
echo "### Step 1 - creating dedicated user 'jira'"
sudo useradd --create-home -c "JIRA role account" {{REMOTE_SERVER_USER}}
sudo useradd --create-home -c "JIRA role account" confluence
echo "### DONE"
echo ""
echo "### Step 3 - creating folders for installing JIRA and JIRA Home"
sudo mkdir /var/atlassian /var/atlassian/application-data
sudo mkdir /var/atlassian/application-data/jira /var/atlassian/application-data/jira/data
sudo mkdir /var/atlassian/application-data/confluence /var/atlassian/application-data/confluence/data
sudo mkdir /opt/atlassian /opt/atlassian/jira /opt/atlassian/confluence
sudo mkdir /jira-files /jira-cache /confluence-files /confluence-cache
echo "### DONE"
echo ""
echo "### Step 4 - changing permissions for jira folders"
sudo chown -R {{REMOTE_SERVER_USER}}:{{REMOTE_SERVER_USER}} /opt/atlassian/jira
sudo chown -R {{REMOTE_SERVER_USER}}:{{REMOTE_SERVER_USER}} /var/atlassian/application-data/jira
sudo chown -R {{REMOTE_SERVER_USER}}:{{REMOTE_SERVER_USER}} /jira-files
sudo chown -R {{REMOTE_SERVER_USER}}:{{REMOTE_SERVER_USER}} /jira-cache
sudo chown -R confluence:confluence /opt/atlassian/confluence
sudo chown -R confluence:confluence /var/atlassian/application-data/confluence
sudo chown -R confluence:confluence /confluence-files
sudo chown -R confluence:confluence /confluence-cache
echo "### DONE"
echo ""
echo "### Step 5 - unpack JIRA and add symlink"
cd /opt/atlassian/jira
sudo su {{REMOTE_SERVER_USER}} -c 'tar -zxf /tmp/atlassian-jira-software-7.6.2.tar.gz'
sudo su {{REMOTE_SERVER_USER}} -c 'ln -s atlassian-jira-software-7.6.2-standalone/ current'
echo "### DONE"
echo ""
echo "### Step 5.1 - unpack confluence and add symlink"
cd /opt/atlassian/confluence
sudo su confluence -c 'tar -zxf /tmp/atlassian-confluence-6.6.1.tar.gz'
sudo su confluence -c 'ln -s atlassian-confluence-6.6.1/ current'
echo ""
echo "### Step 6 - add JIRA home directory to properties"
echo "jira.home=/var/atlassian/application-data/jira" > /opt/atlassian/jira/current/atlassian-jira/WEB-INF/classes/jira-application.properties
echo "confluence.home=/var/atlassian/application-data/confluence" > /opt/atlassian/confluence/current/confluence/WEB-INF/classes/confluence-init.properties
echo "### DONE"
echo ""
echo "### Step 7 - copy config files into install folder"
mv /tmp/jira-server.xml /opt/atlassian/jira/current/conf/server.xml
mv /tmp/confluence-server.xml /opt/atlassian/confluence/current/conf/server.xml
cp /tmp/dbconfig.xml /var/atlassian/application-data/jira/
cp /tmp/dbconfig.xml /var/atlassian/application-data/confluence/
sudo chown -R confluence:confluence /opt/atlassian/confluence
sudo chown -R confluence:confluence /var/atlassian/application-data/confluence
sudo chown -R {{REMOTE_SERVER_USER}}:{{REMOTE_SERVER_USER}} /opt/atlassian/jira
sudo chown -R {{REMOTE_SERVER_USER}}:{{REMOTE_SERVER_USER}} /var/atlassian/application-data/jira
echo "### DONE"
echo ""
echo "##############################################"
echo "#                                            #"
echo "#   Install script for JIRA - DONE           #"
echo "#                                            #"
echo "##############################################"
echo ""
echo ""
echo ""
echo "##############################################"
echo "#                                            #"
echo "#  Configuring SSH Access - START            #"
echo "#                                            #"
echo "##############################################"
echo ""
echo "### Step 1 - Generating RSA-Key"
echo -e 'y\n'|ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa 1> /dev/null
echo "### DONE"
echo ""
echo "### Step 2 - Adding remote host to known_hosts"
ssh-keyscan -t rsa,dsa {{REMOTE_SERVER_IP}} >> ~/.ssh/known_hosts
echo "### DONE"
echo ""
echo "### Step 3 - Copy RSA-Key to remote hosts"
sshpass -p {{REMOTE_SERVER_PASS}} ssh-copy-id {{REMOTE_SERVER_USER}}@{{REMOTE_SERVER_IP}}
echo "### DONE"
echo ""
echo "### Step 4 - Test Connection to remote host and create folder for file storage and cache"
ssh {{REMOTE_SERVER_USER}}@{{REMOTE_SERVER_IP}} "mkdir ~/jira-files ~/jira-cache ~/confluence-files ~/confluence-cache"
echo "### DONE"
echo ""
echo "##############################################"
echo "#                                            #"
echo "#  Configuring SSH Access - DONE             #"
echo "#                                            #"
echo "##############################################"
echo ""
echo ""
echo ""
echo "##############################################"
echo "#                                            #"
echo "#  Starting up services for JIRA - START     #"
echo "#                                            #"
echo "##############################################"
echo ""
echo "### Step 1.1 - Starting up JIRA"
sudo /etc/init.d/jira start
sleep 5
echo "### DONE"
echo ""
echo "### Step 1.2 - Starting up Confluence"
sudo /etc/init.d/confluence start
sleep 5
echo "### DONE"
echo ""
echo "### Step 2 - Starting up nginx"
sudo /etc/init.d/nginx start
echo "### DONE"
echo ""
echo "### Step 3 - Mount file folder"
rm -rf /var/atlassian/application-data/jira/data/attachments
rm -rf /var/atlassian/application-data/jira/data/avatars
rm -rf /var/atlassian/application-data/jira/caches/*
rm -rf /var/atlassian/application-data/confluence/data/*
sshfs -o allow_other -o reconnect -o nonempty -o ServerAliveInterval=15 -o IdentityFile=~/.ssh/id_rsa {{REMOTE_SERVER_USER}}@{{REMOTE_SERVER_IP}}:/home/{{REMOTE_SERVER_USER}}/jira-files /var/atlassian/application-data/jira/data/
sshfs -o allow_other -o reconnect -o nonempty -o ServerAliveInterval=15 -o IdentityFile=~/.ssh/id_rsa {{REMOTE_SERVER_USER}}@{{REMOTE_SERVER_IP}}:/home/{{REMOTE_SERVER_USER}}/jira-cache /var/atlassian/application-data/jira/caches/
sshfs -o allow_other -o reconnect -o nonempty -o ServerAliveInterval=15 -o IdentityFile=~/.ssh/id_rsa {{REMOTE_SERVER_USER}}@{{REMOTE_SERVER_IP}}:/home/{{REMOTE_SERVER_USER}}/jira-cache /var/atlassian/application-data/jira/caches/
echo "### DONE"
echo ""
echo "##############################################"
echo "#                                            #"
echo "#  Starting up services for JIRA - DONE      #"
echo "#                                            #"
echo "##############################################"
