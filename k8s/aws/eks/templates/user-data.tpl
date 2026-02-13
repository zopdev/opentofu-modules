cd ~/
api_key="${nessus_api_key}"
sudo unzip /tmp/agentPackages.zip -d /tmp
sudo chmod +x /tmp/install.sh
sudo /tmp/install.sh -i
sudo rm -f /tmp/install*.sh
sudo rm -f /tmp/agentPackages.zip
sudo /sbin/service nessusagent stop
sudo /opt/nessus_agent/sbin/nessuscli prepare-image
sudo /opt/nessus_agent/sbin/nessuscli agent link --key="$api_key" --cloud --groups="AWS_UTC_MORNING"
sudo /opt/nessus_agent/sbin/nessuscli fix --set process_priority="low"
###  Below commands are for immediate instance Nessus scanning on adhoc basis
#/opt/nessus_agent/sbin/nessuscli fix --set plugin_load_performance_mode=low
#/opt/nessus_agent/sbin/nessuscli fix --set scan_performance_mode=low
#touch /opt/nessus_agent/var/nessus/triggers/scanme
/sbin/service nessusagent restart
sudo yum update -y
