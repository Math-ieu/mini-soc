# Walkthrough: Mini SOC on AWS

I have completed the setup of the mini SOC (Security Operations Center) environment on AWS. Below is a summary of the components and how to use them.

## 1. Infrastructure (Terraform)
The infrastructure is defined in the `terraform/` directory.
- `main.tf`: VPC, Subnet, and Routing (Region: eu-west-3).
- `security_groups.tf`: Firewalls for Wazuh, Shuffle, and Clients.
- `instances.tf`: Definitions for 5 `m7i-flex.large` instances (150GB for SOC, 50GB for Clients).

**To Deploy:**
```bash
cd terraform
terraform init
terraform apply
```

## 2. Configuration (Ansible)
The configuration is handled by Ansible playbooks in the `ansible/` directory.
- `playbooks/setup_wazuh.yml`: Installs Wazuh Manager, Indexer, and Dashboard (Bare-metal).
- `playbooks/setup_shuffle.yml`: Installs Shuffle SOAR via Docker (with DB fixes).
- `playbooks/setup_suricata.yml`: Installs Suricata NIDS.
- `playbooks/setup_clients.yml`: Configures Wazuh Agents and services (Web, FTP) on Linux.

**To Configure:**
1. Update `ansible/inventory.ini` with the public IPs from Terraform output.
2. Run the playbooks:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup_wazuh.yml
ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup_shuffle.yml
ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup_clients.yml
```

## 3. Attack & Response Scenarios
Located in the `scenarios/` directory.
- `attack_simulation.sh`: A script to run against the client servers to generate alerts (SQLi, XSS, Brute Force).
- `shuffle_workflow.json`: A template for Shuffle to automatically block malicious IPs in AWS Security Groups when Wazuh detects an attack.

**To Simulate an Attack:**
```bash
./scenarios/attack_simulation.sh <CLIENT_IP>
```

## 4. Access & Credentials
- **Wazuh (SIEM)**: `https://13.38.41.175`
    - **User**: `admin`
    - **Password**: `mC4WJR+OsgKiNqc98hkRy6BldiL5qUJM`
- **Shuffle (SOAR)**: `http://51.44.165.123:3001`
    - (Initial setup: you will be prompted to create your admin account).

## 🛡 Security Note & Troubleshooting
- **Shuffle Database**: I have applied the following fixes for the database:
    - Disabled memory swap (`sudo swapoff -a`).
    - Allocated `vm.max_map_count=262144`.
    - Set permissions: `sudo chown -R 1000:1000 /opt/shuffle/db`.
    - Disabled internal SSL verification for OpenSearch connection to avoid hostname mismatches.
