
# ANSIBLE NETWORK AUDIT SYSTEM

A complete solution for auditing Linux host password policies across your network using Ansible and Nmap.

## PROJECT STRUCTURE

.
├── html_output
│   └── password_expiry_report.html
├── inventory
│   └── linux_hosts.ini
├── playbook.yml
├── scan_network.sh
└── templates
    └── report_template.j2

## FEATURES

-   Automated network scanning with Nmap
    
-   SSH-based host verification
    
-   Password expiry information collection
    
-   Consolidated HTML reporting
    
-   Customizable user and subnet configurations
    

## PREREQUISITES

### SYSTEM REQUIREMENTS

-   Ansible (v2.9+)
    
-   Nmap (v7.60+)
    
-   Python (v3.6+)
    
-   jinja2 (for template processing)
    
### CONFIGURATION REQUIREMENTS

-   SSH key-based authentication configured
    
-   Sudo privileges on target hosts
    
-   Port 22 open on target hosts
    
-   User with UID 1001 on target hosts
    
## INSTALLATION

1.  Clone the repository:  
    git clone [https://github.com/your-repo/ansible-network-audit.git](https://github.com/your-repo/ansible-network-audit.git)  
    cd ansible-network-audit
    
2.  Make scripts executable:  
    chmod +x scan_network.sh
    
## CONFIGURATION

1.  NETWORK SCANNER CONFIGURATION (scan_network.sh)  
    Edit these variables in the script:

# Valid SSH users to test

USERS=("skills" "admin" "Admin")

# Network subnets to scan

SUBNETS=("192.168.68.0/24" "192.168.86.0/24")

# SSH key path (default: ~/.ssh/id_rsa)

SSH_KEY="~/.ssh/id_rsa"

# Output inventory file

OUTPUT="inventory/linux_hosts.ini"

2.  INVENTORY FILE EXAMPLE  
    Automatically generated after scanning. Sample content:
    

[linux-hosts]  
192.168.68.42 ansible_user=skills  
192.168.68.57 ansible_user=admin

## USAGE

1.  Run network scanner:  
    ./scan_network.sh
    
2.  Execute Ansible playbook:  
    ansible-playbook playbook.yml
    
3.  View the report:  
    xdg-open html_output/password_expiry_report.html
    

## PLAYBOOK DETAILS (playbook.yml)


--   name: Collect password expiry information  
    hosts: linux-hosts  
    gather_facts: no  
    become: yes  
    tasks:
    
    -   name: Find username with UID 1001  
        command: "awk -F: '$3 == 1001 { print $1 }' /etc/passwd"  
        register: user_lookup  
        changed_when: false
        
    -   name: Retrieve password expiry info  
        command: chage -l {{ user_lookup.stdout }}  
        register: chage_output
        
    -   name: Set fact with parsed chage output  
        set_fact:  
        password_info: "{{ chage_output.stdout_lines }}"  
        target_user: "{{ user_lookup.stdout }}"
        
--   name: Generate consolidated HTML report  
    hosts: localhost  
    gather_facts: no  
    vars:  
    report_path: "./html_output/password_expiry_report.html"  
    tasks:
    
    -   name: Ensure output directory exists  
        file:  
        path: "{{ report_path | dirname }}"  
        state: directory  
        mode: '0755'
        
    -   name: Generate HTML report  
        template:  
        src: templates/report_template.j2  
        dest: "{{ report_path }}"
        

## SECURITY CONSIDERATIONS

1.  SSH KEY SECURITY
    

-   Use dedicated audit key with limited privileges
    
-   Set private key permissions: chmod 600
    

2.  SUDO CONFIGURATION RECOMMENDATION  
    Add to sudoers file:  
    %audit ALL = NOPASSWD: /usr/bin/chage -l *
    
3.  REPORT SECURITY
    

-   Store reports in secure location
    
-   Set file permissions: chmod 640 html_output/*
    

## TROUBLESHOOTING

COMMON ISSUES:

1.  SSH Connection Failures
    

-   Verify SSH key permissions
    
-   Test manual SSH connection
    
-   Check firewall settings
    

2.  Permission Denied Errors
    

-   Confirm passwordless sudo configuration
    
-   Verify existence of UID 1001 on targets
    

3.  Empty Inventory File
    

-   Validate subnet configurations
    
-   Check host network connectivity
    

DEBUG MODE:  
Run playbook with: ansible-playbook playbook.yml -vvv

## LICENSE

MIT License

