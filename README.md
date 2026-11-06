# Networking Mini Project — Domain, DNS & EC2

> A hands-on networking project demonstrating how to connect a custom domain to an AWS EC2 instance and serve a website using NGINX.

**Status:** Networking deployment completed — documentation and custom landing page in progress.

---

**1. Project Overview**

This project was completed as part of my Networking module in the CoderCo DevOps Academy.

The objective was to apply networking fundamentals by deploying a web server on AWS EC2, connecting it to a custom domain, and making the website accessible over the internet.

Rather than learning networking concepts in isolation, I wanted to understand how DNS, IP addressing, routing, network security, and HTTP work together in an actual deployment.

What I built

- Registered and configured my domain: `fetudeen.com`
- Launched an Amazon Linux 2 EC2 instance
- Installed and started NGINX(with a user data)
- Configured an Elastic IP for a stable public IPv4 address
- Create hosted zones in AWS Route 53 and I got 4 name servers.
- Configured those name servers in my domain host.
- Created a DNS A record pointing my domain to the Elastic IP
- Configured inbound HTTP access through the EC2 security group
- Verified that my domain resolves to my EC2 instance and displays the NGINX default page

The deployment currently serves the default NGINX landing page over HTTP.

HTTPS and a custom website are planned improvements.

---

**2. Architecture**

The project connects a public domain to a web server hosted on AWS.

                 Internet
                     |
                     v
              fetudeen.com
                     |
                     v
               DNS A Record
                     |
                     v
                Elastic IP
                     |
                     |
                     |
                     v
            AWS's default VPC / Subnet
                     |
                     v
             EC2 Security Group
             Allow inbound TCP 80
                     |
                     v
              Amazon Linux 2
                     |
                     v
                  NGINX
                     |
                     v
              Default Web Page
                     |
                     v
                 Web Browser


Request flow

1. A user enters `http://fetudeen.com` in their browser.
2. DNS resolution retrieves the public IP address associated with the domain.
3. The browser establishes a TCP connection to the EC2 Elastic IP on port 80.
4. AWS networking routes the traffic toward the EC2 instance.
5. The security group evaluates whether the inbound traffic is permitted.
6. The operating system receives the traffic, and NGINX handles the HTTP request.
7. NGINX returns the default webpage.
8. The browser receives the HTTP response and displays the page.

DNS resolution and HTTP communication are separate processes. DNS provides the IP address; it does not establish the HTTP connection or determine whether the server is reachable. 

---

**3. AWS Infrastructure**

### EC2 Instance
| Compute service: Amazon EC2 
| Operating system: Amazon Linux 2 
| Web server: NGINX
| Public addressing: Elastic IP
| Application protocol: HTTP
| HTTP port: TCP 80
| HTTPS: Not configured yet

The EC2 instance provides the compute environment where NGINX runs.

Elastic IP

An Elastic IP is a static public IPv4 address allocated to my AWS account.

I associated an Elastic IP with my EC2 instance to maintain a stable public address when stopping and restarting the instance.

This allows the DNS A record to continue pointing to the same address instead of requiring updates whenever the instance receives a different automatically assigned public IPv4 address.

 Security Group

The EC2 security group controls inbound and outbound traffic associated with the instance's network interface.

The inbound HTTP rule allows traffic to reach the web server.

| Protocol | Port | Purpose |
|----------|------|---------|
| TCP      | 80   | HTTP web traffic |
| TCP      | 22   | SSH administration, restricted to an authorized source |

SSH access should be restricted to a trusted source IP rather than opened to the entire internet.

The security group is stateful, meaning return traffic for permitted connections is automatically allowed.

---

 **4. DNS Configuration**

My domain is:

`fetudeen.com`

The DNS configuration connects the domain name to the public IPv4 address of the EC2 instance--which is the Elastic IP in my case.

### A Record:
| Target | EC2 Elastic IP |
| Purpose | Resolve the domain to the public IPv4 address |

The actual DNS record should contain the Elastic IP assigned to the instance.

DNS Resolution

When a user accesses the domain:

1. The browser and operating system may check their DNS caches.
2. A recursive DNS resolver obtains the required DNS answer if it is not already cached.
3. DNS infrastructure directs the resolver toward the authoritative nameservers for the domain.
4. The authoritative DNS service returns the configured A record.
5. The resolver provides the IP address to the client.

DNS resolution does not verify whether the EC2 instance is running, whether NGINX is listening, or whether the security group allows HTTP traffic.

It only provides the DNS answer.

Verification:
bash
nslookup fetudeen.com

The returned IPv4 address should match the Elastic IP associated with the EC2 instance.


 **5. NGINX Installation and Configuration**

NGINX was installed on the Amazon Linux 2 EC2 instance.

### Install NGINX

```bash
sudo yum install -y nginx
```

### Enable NGINX

```bash
sudo systemctl enable nginx
```

This configures NGINX to start automatically when the instance boots.

### Start NGINX

```bash
sudo systemctl start nginx
```

### Check service status

```bash
sudo systemctl status nginx
```

The expected state is:

```text
Active: active (running)
```

### Verify the listening port

```bash
sudo ss -tlnp
```

NGINX should be listening on TCP port 80.

### Test locally

```bash
curl -v http://localhost
```

This verifies that the local machine can communicate with the web server through HTTP.

### Test using the public IP

```bash
curl -v http://YOUR_ELASTIC_IP
```

### Test using the domain

```bash
curl -v http://fetudeen.com
```

The public IP and domain tests verify different parts of the deployment.

Testing the domain includes DNS resolution, while testing the public IP bypasses the domain lookup.

---

## 6. Networking Concepts Applied

### IP Addressing

An IP address identifies a network interface within an IP network.

The EC2 instance uses private addressing within the VPC and public addressing for internet communication.

The Elastic IP provides a stable public IPv4 address.

### DNS

DNS translates human-readable domain names into IP addresses.

The A record connects `fetudeen.com` to the EC2 public IPv4 address.

DNS resolution does not establish a TCP connection.

### Security Groups

Security groups act as stateful virtual firewalls associated with AWS resources.

They control which network traffic is permitted to reach the instance and which outbound traffic is permitted.

For this project, inbound HTTP traffic uses TCP port 80.

### TCP

TCP provides reliable, connection-oriented communication.

Before HTTP communication begins, the client and server establish a TCP connection using the three-way handshake:

1. SYN
2. SYN-ACK
3. ACK

The connection allows both sides to exchange TCP data.

### HTTP

HTTP is an application-layer protocol used to exchange requests and responses between a client and a web server.

The browser sends an HTTP request, and NGINX returns an HTTP response containing the webpage.

---

## 7. Troubleshooting and Verification

During the deployment, I practiced identifying which part of the networking path could be responsible for a connectivity problem.

The troubleshooting approach was to verify each component instead of assuming that a failed request meant the web server was broken.

### DNS verification

```bash
nslookup fetudeen.com
```

The DNS answer should match the configured Elastic IP.

### Local web server verification

```bash
curl -v http://localhost
```

This tests communication with NGINX locally.

### Public IP verification

```bash
curl -v http://YOUR_ELASTIC_IP
```

This tests HTTP communication using the public IP without relying on DNS resolution.

### Domain verification

```bash
curl -v http://fetudeen.com
```

This tests the domain resolution and HTTP request together.

### NGINX service verification

```bash
sudo systemctl status nginx
```

This checks whether the NGINX service is running.

### Listening socket verification

```bash
sudo ss -tlnp
```

This checks whether NGINX is listening on the expected TCP port.

### Troubleshooting principle

A successful DNS lookup does not prove that the server is reachable.

A running NGINX service does not prove that external traffic can reach it.

A timeout does not automatically identify the cause.

The investigation should consider DNS, routing, security groups, NACLs, operating system firewall rules, TCP connectivity, and the application itself.

---

## 8. Challenges and Lessons Learned

### Connecting DNS to an actual EC2 instance

One of the main objectives was understanding how a domain name connects to a public cloud server.

Configuring the A record made the relationship between DNS resolution and public IP addressing more concrete.

### Understanding Elastic IPs

The Elastic IP helped me understand the difference between an automatically assigned public IPv4 address and a stable public address.

It also demonstrated why stable addressing matters when configuring DNS.

### Separating DNS from connectivity

A domain resolving successfully does not mean the destination is reachable.

DNS resolution and the TCP connection are different stages of communication.

### Understanding security groups

The project demonstrated how security groups control access to network services.

Allowing inbound TCP port 80 makes HTTP access possible, provided the rest of the network path is correctly configured.

### Troubleshooting through evidence

Instead of immediately assuming that NGINX is broken, I learned to investigate the request path and identify what each test actually proves.

This approach is important for diagnosing cloud networking problems.

---

## 9. Screenshots and Evidence

Screenshots will be added to demonstrate the completed deployment.

## 10. Future Improvements

The current deployment is intentionally simple. The next improvements will build on the networking foundation established in this project.

### Custom landing page

Replace the default NGINX page with a minimal personal DevOps progress page.

The page will communicate what I am learning, what I have built, and the concepts I have applied.

### HTTPS

Configure HTTPS using a valid TLS certificate.

This will introduce:

- TLS certificates
- HTTPS
- TCP port 443
- Certificate renewal
- Secure HTTP communication


### Infrastructure as Code

Recreate the infrastructure using Terraform to make the deployment repeatable.

### Automation

Automate NGINX installation and configuration using Bash or configuration management.

---

## 11. Key Takeaways

This project helped connect networking fundamentals with a practical AWS deployment.

I learned how:

- DNS maps a domain name to a public IP address.
- Elastic IPs provide stable public IPv4 addressing.
- AWS routing enables communication between networks.
- Security groups control access to EC2 instances.
- TCP establishes reliable connections.
- HTTP enables communication between browsers and web servers.
- NGINX serves web content on an EC2 instance.
- Troubleshooting requires identifying what each test proves.

Networking is not just about memorizing protocols or commands.

It is about understanding how different components work together to move traffic from a client to a server and back.

---

## 12. Conclusion

This project represents my practical networking deployment as part of my DevOps learning journey.

I connected a custom domain to an AWS EC2 instance, configured stable public addressing, installed NGINX, and verified that the website could be accessed through its domain.

The deployment gave me a practical foundation for understanding DNS, routing, security groups, TCP, and HTTP.

The next step is to replace the default NGINX page with a custom landing page that documents my progress in DevOps.

From here, I will continue building on these networking fundamentals as I move into cloud infrastructure, Docker, Terraform, CI/CD, and Kubernetes.

**Project:** [fetudeen.com](http://fetudeen.com)

**GitHub:** [mini-networking-project](https://github.com/Fetu-Deen/mini-networking-project)

**Learning path:** Networking → Cloud Infrastructure → Containers → Infrastructure as Code → CI/CD → Kubernetes
