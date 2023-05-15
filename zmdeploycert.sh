#!/bin/sh

#Check OS Flavor
is_ubuntu() {
    if [ -f "/etc/lsb-release" ]; then
        grep -q "Ubuntu" /etc/lsb-release
        return $?
    fi
    return 1
}

# Function to check if the Linux distribution is CentOS
is_centos() {
    if [ -f "/etc/redhat-release" ]; then
        grep -q "CentOS" /etc/redhat-release
        return $?
    fi
    return 1
}

# Main script
if is_ubuntu; then
    { cat /etc/lsb-release | grep "DISTRIB_RELEASE" | cut -d '=' -f 2
      sudo apt install certbot python3-certbot-nginx -y
      read -p 'Enter domain: ' domain
      echo "Setting SSL Cert for $domain"
      export EMAIL="mike.cabalin@gmail.com"
      sudo certbot certonly --standalone \
      -d $domain \
      --preferred-chain "ISRG Root X1" \
      --force-renewal \
      --preferred-challenges http \
      --agree-tos \
      -n \
      -m $EMAIL \
      --keep-until-expiring
      mkdir /opt/zimbra/ssl/$domain
      chown -R zimbra:zimbra /opt/zimbra/ssl/$domain
      cp /etc/letsencrypt/archive/$domain/* /opt/zimbra/ssl/$domain/
      read -p 'Enter Company Name: ' company
      echo 'example: devsecops' 
      sudo su - zimbra -c '/opt/zimbra/bin/zmprov cd $company'
      read -p 'Enter Complete Domain Name: ' cdomain
      echo 'example: devsecops.com'
      sleep 2s
      read -p 'Enter Webmail Address Name: ' webmail
      echo 'example: webmail.devsecops.com'
      sudo su - zimbra -c '/opt/zimbra/bin/zmprov md $cdomain zimbraVirtualHostName $webmail'
      sudo su - zimbra -c '/opt/zimbra/libexec/zmdomaincertmgr savecrt $cdomain /opt/zimbra/ssl/$domain/zimbra_chain.pem /opt/zimbra/ssl/$domain/privkey1.pem'
      sudo su - zimbra -c '/opt/zimbra/libexec/zmdomaincertmgr deploycrts'
      sudo su - zimbra -c '/opt/zimbra/libexec/zmdomaincertmgr deploycrts'
      sudo su - zimbra -c '/opt/zimbra/bin/zmprov mcf zimbraReverseProxySNIEnabled TRUE'
      sudo su - zimbra -c '/opt/zimbra/bin/zmcontrol restart'
      }
         
    elif is_centos; then
     { cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' | head -1
       sudo yum -y install epel-release
       sudo yum -y install certbot
       read -p 'Enter domain: ' domain
      echo "Setting SSL Cert for $domain"
      export EMAIL="mike.cabalin@gmail.com"
      sudo certbot certonly --standalone \
      -d $domain \
      --preferred-chain "ISRG Root X1" \
      --force-renewal \
      --preferred-challenges http \
      --agree-tos \
      -n \
      -m $EMAIL \
      --keep-until-expiring
      mkdir /opt/zimbra/ssl/$domain
      chown -R zimbra:zimbra /opt/zimbra/ssl/$domain
      cp /etc/letsencrypt/archive/$domain/* /opt/zimbra/ssl/$domain/
      read -p 'Enter Company Name: ' company
      echo 'example: devsecops' 
      sudo su - zimbra -c '/opt/zimbra/bin/zmprov cd $company'
      read -p 'Enter Complete Domain Name: ' cdomain
      echo 'example: devsecops.com'
      sleep 2s
      read -p 'Enter Webmail Address Name: ' webmail
      echo 'example: webmail.devsecops.com'
      sudo su - zimbra -c '/opt/zimbra/bin/zmprov md $cdomain zimbraVirtualHostName $webmail'
      sudo su - zimbra -c '/opt/zimbra/libexec/zmdomaincertmgr savecrt $cdomain /opt/zimbra/ssl/$domain/zimbra_chain.pem /opt/zimbra/ssl/$domain/privkey1.pem'
      sudo su - zimbra -c '/opt/zimbra/libexec/zmdomaincertmgr deploycrts'
      sudo su - zimbra -c '/opt/zimbra/libexec/zmdomaincertmgr deploycrts'
      sudo su - zimbra -c '/opt/zimbra/bin/zmprov mcf zimbraReverseProxySNIEnabled TRUE'
      sudo su - zimbra -c '/opt/zimbra/bin/zmcontrol restart'
      }
else
    echo "Unsupported Linux distribution."
fi

sleep 10s

exit
