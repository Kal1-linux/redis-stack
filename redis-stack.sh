#!/bin/bash

# Root privilege check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Adding the GPG key for Redis Stack
echo "Adding the GPG key for Redis Stack..."
curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

# Adding the Redis Stack repository
echo "Adding the Redis Stack repository..."
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list

# Updating package lists and installing Redis Stack
echo "Updating package lists and installing Redis Stack..."
apt-get update
apt-get install redis-stack-server -y

# Configure Redis Stack
echo "Configuring Redis Stack..."
redis_conf="/opt/redis-stack/etc/redis-stack.conf"  # Adjust this path based on your findings
sed -i '/^bind/s/^/#/' $redis_conf
sed -i '/^appendonly/s/^/#/' $redis_conf
echo "maxmemory 2gb" >> $redis_conf
echo "maxmemory-policy allkeys-lru" >> $redis_conf
echo "appendonly no" >> $redis_conf
echo "bind 0.0.0.0" >> $redis_conf




#configure for redis-stack.conf
echo "protected-mode no" >> /etc/redis-stack.conf


# System optimizations
echo "Applying system optimizations..."
sysctl -w net.core.somaxconn=1024
sysctl vm.overcommit_memory=1
echo "fs.file-max = 100000" >> /etc/sysctl.conf
echo "* soft nofile 65535" >> /etc/security/limits.conf
echo "* hard nofile 65535" >> /etc/security/limits.conf

# Enable and start Redis Stack service
echo "Enabling and starting Redis Stack service..."
systemctl enable redis-stack-server
systemctl start redis-stack-server

# Check the status of Redis Stack service
echo "Redis Stack installation and configuration complete. Checking the service status..."
systemctl status redis-stack-server
