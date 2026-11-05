#1 Troubleshooting: Nginx Was Not Running on EC2

### Problem
After configuring EC2 User Data to install and start Nginx, the web server was not running. Consequently, the website was inaccessible.

### Investigation
1. Checked cloud-init execution status using `sudo cloud-init status --long`.
2. Inspected `/var/log/cloud-init-output.log` and found a warning indicating that the original User Data was not recognized as an executable shell script.
3. Verified the stored User Data using `/var/lib/cloud/instance/user-data.txt`.
4. Checked whether Nginx was installed using `rpm -q nginx`; the package was not installed.

### Root Cause
The original User Data script lacked a `#!/bin/bash` shebang, and cloud-init reported that it was not handled as a shell script.

Additionally, editing User Data and stopping/starting the existing EC2 instance did not automatically rerun the initialization script. EC2 User Data normally executes during the initial instance launch.

### Resolution
Installed and started Nginx manually:

```bash
sudo dnf install -y nginx
sudo systemctl enable --now nginx
```

Verified that Nginx was running and serving HTTP requests:

```bash
sudo systemctl status nginx
curl http://localhost
```

### Key Takeaways
- Cloud-init reporting `done` does not guarantee that every User Data command succeeded.
- User Data shell scripts should include the appropriate shebang.
- User Data normally executes during the instance's initial launch, not every reboot or stop/start cycle.
- `systemctl enable` configures a service to start automatically on future boots, while `systemctl start` starts it immediately.
- Manual fixes can create configuration drift between the actual instance state and its provisioning script.
