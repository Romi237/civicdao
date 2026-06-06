# CivicDAO — Quick Deploy to Your VPS

Follow these steps to deploy CivicDAO to your Ubuntu VPS in minutes!

## What You Need
1. An Ubuntu VPS (22.04 LTS or later recommended)
2. SSH access to your VPS (as root user)
3. Git and Ansible installed on your local machine

---

## Step 0: Wipe/Reinstall Your VPS (Optional but Highly Recommended)

If your VPS already has other things installed, it's best to start fresh! This will erase everything on your VPS and give you a clean Ubuntu installation!

### How to Do This:
1. Log in to your VPS provider's control panel (e.g., Contabo, DigitalOcean, AWS)
2. Find your VPS in the list
3. Look for an option like **"Reinstall"**, **"Reset"**, **"Wipe"**, or **"Rebuild"**
4. Choose **Ubuntu 22.04 LTS** or **Ubuntu 24.04 LTS** (latest LTS version recommended)
5. Confirm the reinstallation—this may take 5-15 minutes
6. Once done, your VPS provider will give you a new root password (save this!)

---

---

## Step 1: Set Up Your Local Machine (CRITICAL!)

This will prepare your computer to deploy the app!

### 1.1 Install Git
Git lets you download the app code from GitHub.

- **Windows**:
  1. Go to https://git-scm.com/download/win
  2. Download and run the installer
  3. Use the default settings (just click "Next" until it's done)
  4. Open "Git Bash" from your Start menu—this is what we'll use for all commands!

- **macOS**:
  Open Terminal and run:
  ```bash
  brew install git
  ```

- **Linux**:
  Open Terminal and run:
  ```bash
  sudo apt update && sudo apt install git -y
  ```

### 1.2 Install Ansible
Ansible automates the deployment process for you!

- **Windows (using Git Bash)**:
  1. Open Git Bash
  2. First, make sure Python and pip are installed:
     ```bash
     python --version
     pip --version
     ```
  3. If you don't have pip, install Python from https://www.python.org/ (make sure to check "Add Python to PATH" during installation)
  4. Then install Ansible:
     ```bash
     pip install ansible
     ```

- **macOS**:
  Open Terminal and run:
  ```bash
  brew install ansible
  ```

- **Linux**:
  Open Terminal and run:
  ```bash
  sudo apt update && sudo apt install ansible -y
  ```

### 1.3 Verify Your Installations
Let's make sure everything is installed correctly! Open Git Bash (Windows) or Terminal (macOS/Linux) and run:
```bash
git --version
ansible --version
```
You should see version numbers for both—no errors!

---

## Step 2: Prepare Your Ubuntu VPS (CRITICAL!)

First, let's make sure your VPS is ready for deployment! You need to do this **before** running the Ansible playbooks!

### 2.1 Log In to Your VPS
First, log in to your VPS as root using SSH:
```bash
ssh root@YOUR_VPS_IP
```
(Replace `YOUR_VPS_IP` with your actual VPS IP address)

### 2.2 Update Your VPS
Let's make sure your VPS has the latest security updates and packages:
```bash
apt update && apt upgrade -y
```
This may take a few minutes—wait for it to finish!

### 2.3 Verify Your VPS is Ubuntu
Let's make sure you're running Ubuntu (22.04 or later):
```bash
lsb_release -a
```
You should see "Ubuntu" in the output!

### 2.4 Configure Your VPS Provider's Firewall
Most VPS providers (Contabo, DigitalOcean, AWS, etc.) have a **cloud firewall** in their control panel! You **must** add these inbound rules:
- Allow **Port 22 (SSH)**: For you to connect
- Allow **Port 80 (HTTP)**: For web traffic
- Allow **Port 443 (HTTPS)**: For secure web traffic
- **Source**: 0.0.0.0/0 (allow from anywhere, or just your IP for better security)

Save the firewall settings!

### 2.5 Log Out of Your VPS
For now, you can log out:
```bash
exit
```

---

## Step 3: Clone the Repository
On your local machine:
```bash
git clone https://github.com/Romi237/civicdao.git
cd civicdao/civicdao_new/ansible
```

---

## Step 4: Configure Your Inventory
Copy the example inventory file and edit it:
```bash
cp inventory.example.yml inventory.yml
```

Open `inventory.yml` in your editor and replace:
- `YOUR_VPS_IP_ADDRESS` with your VPS's public IP address
- Optional: Change `git_branch` if you want a different branch

---

## Step 5: Set Up SSH Access to Your VPS
Make sure you can SSH into your VPS without a password (recommended):
1. Generate an SSH key pair if you don't have one:
   ```bash
   ssh-keygen -t ed25519 -C "civicdao-deploy"
   ```
2. Copy your public key to your VPS:
   ```bash
   ssh-copy-id root@YOUR_VPS_IP
   ```

---

## Step 6: Run the Ansible Playbooks!
### Provision Your VPS (Installs Docker, Security Tools, etc.)
```bash
ansible-playbook -i inventory.yml setup_server.yml
```

### Deploy the Application!
```bash
ansible-playbook -i inventory.yml deploy_app.yml
```

---

## Step 7: Access Your Deployed App
- **Backend Health Check**: `http://YOUR_VPS_IP/health`
- **Backend API Base URL**: `http://YOUR_VPS_IP/api`
- **Grafana Dashboard**: Access via SSH tunnel:
  ```bash
  ssh -L 3001:localhost:3001 root@YOUR_VPS_IP
  ```
  Then open http://localhost:3001 in your browser (credentials are in `/opt/civicdao/app/civicdao_new/.env` on your VPS)

---

## Troubleshooting
- **Connection Timed Out**: Make sure your VPS provider's firewall allows ports 22, 80, 443
- **Permission Denied**: Double-check your SSH key or root password
- **For more help, check the full README in the `ansible/` directory!**
