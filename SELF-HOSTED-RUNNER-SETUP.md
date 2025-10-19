# Self-Hosted GitHub Actions Runner Setup Guide

This guide will help you set up self-hosted GitHub Actions runners for your Todo Application CI/CD pipeline.

## 🎯 Overview

The pipeline has been configured to run on self-hosted runners with the following labels:
- `self-hosted`
- `linux` 
- `x64`

## 📋 Prerequisites

### System Requirements
- **OS**: Ubuntu 20.04+ or CentOS 8+ (Linux)
- **CPU**: 2+ cores recommended
- **RAM**: 4GB+ recommended
- **Storage**: 20GB+ free space
- **Network**: Stable internet connection

### Software Requirements
- **Docker**: For container builds and PostgreSQL service
- **Node.js**: Version 18+ (will be installed by setup-node action)
- **Git**: For code checkout
- **curl**: For downloading runner

## 🚀 Installation Steps

### 1. Prepare the Server

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl wget git unzip

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login again to apply docker group changes
```

### 2. Create Runner User (Recommended)

```bash
# Create a dedicated user for the runner
sudo useradd -m -s /bin/bash github-runner
sudo usermod -aG docker github-runner

# Switch to the runner user
sudo su - github-runner
```

### 3. Download and Configure Runner

```bash
# Create runner directory
mkdir actions-runner && cd actions-runner

# Download the latest runner package
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Extract the installer
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# Configure the runner (replace with your values)
./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_REGISTRATION_TOKEN
```

### 4. Get Registration Token

1. Go to your GitHub repository
2. Navigate to **Settings** → **Actions** → **Runners**
3. Click **New self-hosted runner**
4. Select **Linux** and **x64**
5. Copy the registration token from the command shown

### 5. Install Runner as Service

```bash
# Install the runner as a service
sudo ./svc.sh install

# Start the service
sudo ./svc.sh start

# Check service status
sudo ./svc.sh status
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file for the runner:

```bash
# Create environment file
sudo nano /home/github-runner/.env

# Add the following content:
NODE_ENV=production
DOCKER_BUILDKIT=1
COMPOSE_DOCKER_CLI_BUILD=1
```

### Docker Configuration

```bash
# Configure Docker daemon for better performance
sudo nano /etc/docker/daemon.json

# Add the following content:
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "default-address-pools": [
    {
      "base": "172.17.0.0/12",
      "size": 24
    }
  ]
}

# Restart Docker
sudo systemctl restart docker
```

### Runner Labels

The runner will automatically have these labels:
- `self-hosted`
- `linux`
- `x64`

You can add custom labels during configuration:
```bash
./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN --labels "production,web,api"
```

## 🧪 Testing the Setup

### 1. Test Runner Connection

```bash
# Check if runner is online
# Go to GitHub repository → Settings → Actions → Runners
# You should see your runner listed as "Online"
```

### 2. Test Pipeline

```bash
# Make a small change to trigger the pipeline
echo "# Test" >> README.md
git add README.md
git commit -m "Test self-hosted runner"
git push origin dev
```

### 3. Monitor Pipeline Execution

1. Go to **Actions** tab in your GitHub repository
2. Check the workflow run
3. Verify it's using your self-hosted runner
4. Check logs for any issues

## 🔒 Security Considerations

### 1. Network Security

```bash
# Configure firewall
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 443
sudo ufw allow 80

# Block unnecessary ports
sudo ufw deny 22/tcp
sudo ufw allow from YOUR_IP to any port 22
```

### 2. Runner Security

```bash
# Create isolated environment for runners
sudo mkdir -p /opt/github-runners
sudo chown github-runner:github-runner /opt/github-runners

# Use dedicated network for Docker
docker network create --driver bridge github-runner-net
```

### 3. Secrets Management

```bash
# Store secrets securely
sudo mkdir -p /etc/github-runner/secrets
sudo chmod 700 /etc/github-runner/secrets

# Add secrets to environment
echo "DOCKERHUB_TOKEN=your_token" | sudo tee /etc/github-runner/secrets/dockerhub
```

## 📊 Monitoring and Maintenance

### 1. Runner Monitoring

```bash
# Check runner status
sudo systemctl status actions.runner.*

# View runner logs
sudo journalctl -u actions.runner.* -f

# Check disk usage
df -h /home/github-runner
```

### 2. Performance Optimization

```bash
# Configure swap (if needed)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Add to /etc/fstab for persistence
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 3. Cleanup Scripts

Create cleanup script:

```bash
# Create cleanup script
sudo nano /home/github-runner/cleanup.sh

# Add the following content:
#!/bin/bash
# Clean up Docker resources
docker system prune -f
docker volume prune -f

# Clean up old logs
sudo journalctl --vacuum-time=7d

# Clean up temporary files
rm -rf /tmp/github-runner-*
```

```bash
# Make executable and schedule
sudo chmod +x /home/github-runner/cleanup.sh
sudo crontab -e

# Add daily cleanup at 2 AM
0 2 * * * /home/github-runner/cleanup.sh
```

## 🚨 Troubleshooting

### Common Issues

1. **Runner Not Appearing Online**
   ```bash
   # Check service status
   sudo systemctl status actions.runner.*
   
   # Restart service
   sudo ./svc.sh stop
   sudo ./svc.sh start
   ```

2. **Docker Permission Issues**
   ```bash
   # Add user to docker group
   sudo usermod -aG docker github-runner
   
   # Restart service
   sudo ./svc.sh restart
   ```

3. **Network Connectivity Issues**
   ```bash
   # Test connectivity
   curl -I https://github.com
   
   # Check DNS
   nslookup github.com
   ```

4. **Disk Space Issues**
   ```bash
   # Check disk usage
   df -h
   
   # Clean up Docker
   docker system prune -a -f
   ```

### Log Analysis

```bash
# View runner logs
sudo journalctl -u actions.runner.* --since "1 hour ago"

# View Docker logs
sudo journalctl -u docker --since "1 hour ago"

# View system logs
sudo journalctl --since "1 hour ago" | grep -i error
```

## 🔄 Multiple Runners Setup

### For High Availability

```bash
# Set up multiple runners on different servers
# Each runner should have unique names:

# Runner 1
./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token TOKEN --name "runner-1"

# Runner 2  
./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token TOKEN --name "runner-2"
```

### Load Balancing

```bash
# Configure runners with different capabilities
# Runner 1: General purpose
./config.sh --labels "self-hosted,linux,x64,general"

# Runner 2: Docker builds
./config.sh --labels "self-hosted,linux,x64,docker"
```

## 📈 Performance Tuning

### 1. Resource Allocation

```bash
# Monitor resource usage
htop
iotop
nethogs

# Adjust runner concurrency
# Edit runner configuration
sudo nano /home/github-runner/.runner
```

### 2. Docker Optimization

```bash
# Configure Docker for better performance
sudo nano /etc/docker/daemon.json

{
  "max-concurrent-downloads": 3,
  "max-concurrent-uploads": 5,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

## 🆘 Support

### Getting Help

1. **GitHub Actions Documentation**: https://docs.github.com/en/actions/hosting-your-own-runners
2. **Runner Issues**: Check GitHub Issues for the actions/runner repository
3. **Community Support**: GitHub Community Forum

### Emergency Procedures

```bash
# Stop all runners
sudo ./svc.sh stop

# Remove runner
sudo ./svc.sh uninstall
./config.sh remove --token YOUR_TOKEN

# Clean installation
sudo rm -rf /home/github-runner/actions-runner
```

## ✅ Verification Checklist

- [ ] Runner appears online in GitHub repository settings
- [ ] Pipeline jobs are assigned to self-hosted runner
- [ ] Tests run successfully
- [ ] Docker builds complete
- [ ] Security scans execute
- [ ] Deployment steps run
- [ ] Logs are accessible
- [ ] Performance is acceptable
- [ ] Security measures are in place
- [ ] Monitoring is configured

Your self-hosted GitHub Actions runner is now ready to execute the Todo Application CI/CD pipeline!
