
# Generate a list of valid values using the ls command
valid_values=($(ls /sys/class/net/))


# Display all valid values with indexes
echo "Danh sach ten cac card mang:"
for index in "${!valid_values[@]}"; do
    echo "$index: ${valid_values[index]}"
done


while true; do
    # Request user input for index of variable 1
    read -p "Nhap id card mang 1G so 1: " index_C1G1
    C1G1="${valid_values[index_C1G1]}"

    # Request user input for index of variable 2
    read -p "Nhap id card mang 1G so 2: " index_C1G2
    C1G2="${valid_values[index_C1G2]}"

    # Request user input for index of variable 3
    read -p "Nhap id card mang 10G so 1: " index_C10G1
    C10G1="${valid_values[index_C10G1]}"

    # Request user input for index of variable 4
    read -p "Nhap id card mang 10G so 2: " index_C10G2
    C10G2="${valid_values[index_C10G2]}"

    # Display entered variables
    echo -e "\nYou entered:"
    echo "Variable 1: $C1G1"
    echo "Variable 2: $C1G2"
    echo "Variable 3: $C10G1"
    echo "Variable 4: $C10G2"

    # Check if entered variables are in the valid list
    if [[ " ${valid_values[@]} " =~ " $C1G1 " && " ${valid_values[@]} " =~ " $C1G2 " && " ${valid_values[@]} " =~ " $C10G1 " && " ${valid_values[@]} " =~ " $C10G2 " ]]; then
        echo -e "\nAll variables are in the valid list."
    else
        echo -e "\nPlease enter valid values for all variables. Retry."
        continue
    fi

    # Ask for confirmation
    read -p "Are these correct? (yes/no): " confirmation

    # Check if the user entered 'yes' to exit the loop
    if [ "$confirmation" = "yes" ]; then
        echo "Confirmation received. Continue."
        break
    else
        echo "Please try again."
    fi
done
ip_address="42.115.20.44"
subnet="27"


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