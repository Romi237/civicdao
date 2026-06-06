# CivicDAO Ansible Deployment Guide

This guide will help you deploy CivicDAO to any Ubuntu VPS using Ansible!

## Prerequisites
1. An Ubuntu VPS (22.04 or later recommended)
2. SSH access to your VPS (as root)
3. Ansible installed on your local machine
   - On Windows: Use Git Bash or WSL, install Ansible via pip
   - On macOS/Linux: `brew install ansible` or `apt install ansible`

## Step 1: Prepare Your Local Machine
1. Clone this repository (if you haven't already):
   ```bash
   git clone https://github.com/Romi237/civicdao.git
   cd civicdao/civicdao_new
   ```
2. Make sure you can SSH into your VPS without a password (recommended):
   - On your local machine, generate an SSH key if you don't have one:
     ```bash
     ssh-keygen -t ed25519 -C "civicdao-deploy"
     ```
   - Copy your public key to the VPS:
     ```bash
     ssh-copy-id root@YOUR_VPS_IP
     ```

## Step 2: Configure Ansible Inventory
1. Copy the example inventory file:
   ```bash
   cd ansible
   cp inventory.example.yml inventory.yml
   ```
2. Edit `inventory.yml` and replace:
   - `YOUR_VPS_IP_ADDRESS` with your VPS's public IP
   - `git_branch` (optional) if you want to deploy a different branch

## Step 3: Provision the VPS
This will install Docker, configure the firewall, and set up security:
```bash
ansible-playbook -i inventory.yml setup_server.yml
```

## Step 4: Deploy the Application
This will clone the repo, generate secrets, and start all services:
```bash
ansible-playbook -i inventory.yml deploy_app.yml
```

## Step 5: Verify Deployment
Once deployed, access your services at:
- **Backend Health Check**: `http://YOUR_VPS_IP/health`
- **Backend API**: `http://YOUR_VPS_IP/api`
- **Grafana** (via SSH tunnel):
  ```bash
  ssh -L 3001:localhost:3001 root@YOUR_VPS_IP
  ```
  Then open http://localhost:3001 in your browser (login credentials are in `/opt/civicdao/app/civicdao_new/.env` on the VPS)

## Notes
- The app will be deployed to `/opt/civicdao/app/civicdao_new` on the VPS
- All passwords are auto-generated and stored in `.env` files on the VPS
- The Docker Compose stack includes: MongoDB, Backend, Nginx, Prometheus, Grafana, Node Exporter
