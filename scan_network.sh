#!/bin/bash
USERS=("skills" "admin" "Admin")
SUBNETS=("192.168.68.0/24" "192.168.86.0/24")

SSH_KEY="~/.ssh/id_rsa"
OUTPUT="inventory/linux_hosts.ini"

mkdir -p "$(dirname "$OUTPUT")"

echo "[linux-hosts]" > "$OUTPUT"

for SUBNET in "${SUBNETS[@]}"; do
  echo "🔍 Scanning $SUBNET..."

  # Disable DNS resolution with -n
  HOSTS=$(sudo nmap -n -p 22 --open "$SUBNET" -T4 | awk '/Nmap scan report for/ { print $NF }')

  for HOST in $HOSTS; do
    echo "🔌 Testing SSH for $HOST..."

    for USER in "${USERS[@]}"; do
      echo "   ↪ Trying $USER@$HOST..."

      if ssh -i "$SSH_KEY" -o BatchMode=yes -o ConnectTimeout=3 "$USER@$HOST" "exit" &>/dev/null; then
        echo "$HOST ansible_user=$USER" >> "$OUTPUT"
        echo "✅ $HOST is reachable as $USER"
        break
      fi
    done
  done
done

echo "✅ Scan complete. Inventory saved to $OUTPUT."

