
# Generate a list of valid values using the ls command
is_valid_ip() {
    local ip=$1
    local regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

    if [[ $ip =~ $regex ]]; then
        return 0  # Valid IP address
    else
        return 1  # Invalid IP address
    fi
}

while true; do

  # ======================================== INTERFACE ========================================
  while true; do
    echo  && echo "NETWORK INTERFACE" 
    echo "----------"

    # Display all valid values with indexes
    valid_values=($(ls /sys/class/net/))
    echo "List of all interfaces:"
    for index in "${!valid_values[@]}"; do
        echo "$index: ${valid_values[index]}"
    done
    echo "----------"
    # Request user input for index of variable 3
    read -p "Card 10G - 1: " index_C10G1
    C10G1="${valid_values[index_C10G1]}"

    # Request user input for index of variable 4
    read -p "Card 10G - 2: " index_C10G2
    C10G2="${valid_values[index_C10G2]}"

    # Check if entered variables are in the valid list
    if [[  " ${valid_values[@]} " =~ " $C10G1 " && " ${valid_values[@]} " =~ " $C10G2 " ]]; then
        echo "----------"
        echo "All index are in the valid list."
        echo "----------"
        break
    else
        echo "----------"
        echo "Please enter valid index for all card. Retry."
        echo "----------"
        continue
    fi
  done



  while true; do
    echo && echo  "IP ADDRESS"
    read -p "Give us IP address for this server: " ip_address
    if is_valid_ip "$ip_address"; then
        echo "----------"
        echo  "IP address is valid."
        echo "----------"
        break
    else
        echo "----------"
        echo "Please enter valid IP address. Retry."
        echo "----------"
        continue
    fi
  done


  while true; do
      echo && echo "SUBNET PREFIX" 
      read -p "How about the subnet prefix: " subnet_prefix
      if [[ $subnet_prefix =~ ^[0-9]+$ ]] && [ $subnet_prefix -ge 0 ] && [ $subnet_prefix -le 32 ]; then
          echo "----------"
          echo "Subnet prefix is valid: $subnet_prefix"
          echo "----------"
          break
      else
          echo "----------"
          echo "Please enter valid subnet prefix. Retry."
          echo "----------"
      fi
  done

  gateway=''
  subnet_bit=$((0xFFFFFFFF << (32 - subnet_prefix)))
  subnet_mask=$((subnet_bit >> 24 & 255)).$((subnet_bit >> 16 & 255)).$((subnet_bit >> 8 & 255)).$((subnet_bit & 255))
  IFS=. read -r -a ip_parts <<< "$ip_address"
  IFS=. read -r -a subnet_parts <<< "$subnet_mask"
  for ((i=0; i<4; i++)); do
    if [ $i -eq 3 ]; then    
      gateway_part=$((ip_parts[i] &( subnet_parts[i] )  | 1 ))
    else
      gateway_part=$((ip_parts[i] & subnet_parts[i]))
    fi
    gateway+="$gateway_part"
    if [ $i -lt 3 ]; then
      gateway+="."
    fi
  done
  echo && echo "SUMMARIZE"
  echo "----------"
  # Display entered variables
  echo "You entered:"
  echo "- 10G interface 1: $C10G1"
  echo "- 10G interface 2: $C10G2"&& echo
  echo "- IP address: $ip_address/$subnet_prefix"
  echo "- Subnet mask: $subnet_mask"
  echo "- Gateway: $gateway"
  echo "----------"
  # ======================================== CONFIRM ========================================
  # Ask for confirmation
  echo && echo "CONFIRM" 
  echo "----------"
  read -p "Are these correct? (yes/no): " confirmation
  # Check if the user entered 'yes' to exit the loop
  if [ "$confirmation" = "yes" ]; then
      echo "Confirmation received. Continue."
      echo "----------"

      echo && echo "CONFIGURATION" 
      echo "----------"
      echo "Backing up"
      new_folder="/home/ansible/netConfigBK_$(date +%Y%m%d-%H%M%S)" && mkdir -p "$new_folder" && cp /etc/sysconfig/network-scripts/ifcfg-* "$new_folder"
      
      echo "Config Card 10Gb - 1"
      sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/g' /etc/sysconfig/network-scripts/ifcfg-$C10G1
      sed -i 's/ONBOOT=no/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-$C10G1
      echo -e "MASTER=bond0\nSLAVE=yes\nUSERCTL=no" >> /etc/sysconfig/network-scripts/ifcfg-$C10G1
      
      echo "Config Card 10Gb - 2"
      sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/g' /etc/sysconfig/network-scripts/ifcfg-$C10G2
      sed -i 's/ONBOOT=no/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-$C10G2
      echo -e "MASTER=bond0\nSLAVE=yes\nUSERCTL=no" >> /etc/sysconfig/network-scripts/ifcfg-$C10G2

      echo "Reset bond0 config"
      echo -e "DEVICE=bond0 \nIPADDR=THIS_IS_IP\nPREFIX=THIS_IS_NETMASK\nGATEWAY=THIS_IS_GATEWAY\nUSERCTL=no\nBOOTPROTO=none\nBONDING_MASTER=yes\nONBOOT=yes\nBONDING_OPTS=\"mode=4 miimon=100 lacp_rate=1\""  > /etc/sysconfig/network-scripts/ifcfg-bond0
     
      echo "Config IP address"
      sed -i "s/THIS_IS_IP/$ip_address/g" /etc/sysconfig/network-scripts/ifcfg-bond0

      echo "Config subnet-mask"
      sed -i "s/THIS_IS_NETMASK/$subnet_prefix/g"  /etc/sysconfig/network-scripts/ifcfg-bond0

      echo "Config gateway"
      sed -i "s/THIS_IS_GATEWAY/$gateway/g" /etc/sysconfig/network-scripts/ifcfg-bond0

      echo "Restart NetworkManager"
      systemctl restart network
      
      echo "----------"
      echo "All done."
      echo "----------"

      break
  else
      echo "----------"
      echo "Please try again."
      echo "----------"
  fi
done







