
# Generate a list of valid values using the ls command
echo "[Info section]"
valid_values=($(ls /sys/class/net/))

# Display all valid values with indexes
echo "List of all interfaces:"
for index in "${!valid_values[@]}"; do
    echo "$index: ${valid_values[index]}"
done
echo "----------"
while true; do
    # Request user input for index of variable 1
    read -p "Enter the index for 1G interface 1: " index_C1G1
    C1G1="${valid_values[index_C1G1]}"

    # Request user input for index of variable 2
    read -p "Enter the index for 1G interface 2: " index_C1G2
    C1G2="${valid_values[index_C1G2]}"

    echo ""
    # Request user input for index of variable 3
    read -p "Enter the index for 10G interface 1: " index_C10G1
    C10G1="${valid_values[index_C10G1]}"

    # Request user input for index of variable 4
    read -p "Enter the index for 10G interface 2: " index_C10G2
    C10G2="${valid_values[index_C10G2]}"

    echo "----------"
    # Display entered variables
    echo "You entered:"
    echo "- 1G interface 1: $C1G1"
    echo "- 1G interface 2: $C1G2"
    echo "- 10G interface 1: $C10G1"
    echo "- 10G interface 2: $C10G2"

    echo "----------"
    # Check if entered variables are in the valid list
    if [[ " ${valid_values[@]} " =~ " $C1G1 " && " ${valid_values[@]} " =~ " $C1G2 " && " ${valid_values[@]} " =~ " $C10G1 " && " ${valid_values[@]} " =~ " $C10G2 " ]]; then
        echo "All variables are in the valid list."
    else
        echo "Please enter valid values for all variables. Retry."
        continue
    fi

    echo "----------"
    # Ask for confirmation
    read -p "Are these correct? (yes/no): " confirmation

    # Check if the user entered 'yes' to exit the loop
    if [ "$confirmation" = "yes" ]; then
        echo "Confirmation received. Continue."
        break
    else
        echo "Please try again."
        echo "----------"
    fi
done

echo "==============="
while true; do
    read -p "Give us IP address for this server: " ip_address
    # Ask for confirmation
    read -p "Are these correct? (yes/no): "
    if [[ $confirm == "yes" ]]; then
        echo "Confirmation received. Continue."
        break
    else
        echo "Please try again."
        echo "----------"
    fi
done

echo "==============="
while true; do
    read -p "How about the subnet prefix: " subnet_prefix
    if [[ $subnet_prefix =~ ^[0-9]+$ ]] && [ $subnet_prefix -ge 0 ] && [ $subnet_prefix -le 32 ]; then
        echo "Subnet prefix is valid: $subnet_prefix"
        break
    else
        echo "Please enter valid subnet prefix. Retry."
    fi
    read -p "Are these correct? (yes/no): "
    if [[ $confirm == "yes" ]]; then
        echo "Confirmation received. Continue."
        break
    else
        echo "Please try again."
        echo "----------"
    fi
done



gateway=''
subnet_bit=$((0xFFFFFFFF << (32 - subnet)))
subnet=$((subnet_bit >> 24 & 255)).$((subnet_bit >> 16 & 255)).$((subnet_bit >> 8 & 255)).$((subnet_bit & 255))
IFS=. read -r -a ip_parts <<< "$ip_address"
IFS=. read -r -a subnet_parts <<< "$subnet"
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


echo $gateway