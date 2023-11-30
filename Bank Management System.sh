#!/bin/bash

# Bank Management System

# File to store customer account information
account_info_file="bankAccountInfo.csv"

# File to store transaction history
transaction_history_file="transactionHistory.csv"

# Function to create a new customer account
new_account() {
  clear
  echo "Enter the customer's name: "
  read customer_name

  echo "Enter the customer's National ID (NID) number: "
  read nid_number

  echo "Enter the initial deposit amount: "
  read initial_deposit

  # Generate a unique account number (you may implement your logic for this)
  account_number=$(date +%s%N | md5sum | head -c10)

  # Append the new account information to the account info file
  echo "$account_number,$customer_name,$nid_number,$initial_deposit" >> "$account_info_file"

  # Display a message to the user indicating that the new customer account has been created
  echo "Customer account created successfully!"
}

# Function to perform a deposit
deposit() {
  clear
  echo "Enter National ID (NID) number for deposit: "
  read nid_number

  # Check if the NID exists
  if grep -q "$nid_number" "$account_info_file"; then
    echo "Enter deposit amount: "
    read deposit_amount

    # Update account balance
    awk -v nid="$nid_number" -v dep_amt="$deposit_amount" -F, '$3==nid { $4 = $4 + dep_amt }1' "$account_info_file" > temp && mv temp "$account_info_file"

    # Record the transaction in the transaction history file
    echo "$(date '+%Y-%m-%d %H:%M:%S'),$nid_number,Deposit,$deposit_amount" >> "$transaction_history_file"

    echo "Deposit successful!"
  else
    echo "NID not found!"
  fi
}

# Function to perform a withdrawal
withdrawal() {
  clear
  echo "Enter National ID (NID) number for withdrawal: "
  read nid_number

  # Check if the NID exists
  if grep -q "$nid_number" "$account_info_file"; then
    echo "Enter withdrawal amount: "
    read withdrawal_amount

    # Check if there are sufficient funds
    current_balance=$(awk -v nid="$nid_number" -F, '$3==nid {print $4}' "$account_info_file")
    if [ -z "$current_balance" ]; then
      echo "NID not found!"
    else
      if [ "$current_balance" -lt "$withdrawal_amount" ]; then
        echo "Insufficient funds!"
      else
        # Update account balance
        awk -v nid="$nid_number" -v with_amt="$withdrawal_amount" -F, '$3==nid { $4 = $4 - with_amt }1' "$account_info_file" > temp && mv temp "$account_info_file"

        # Record the transaction in the transaction history file
        echo "$(date '+%Y-%m-%d %H:%M:%S'),$nid_number,Withdrawal,$withdrawal_amount" >> "$transaction_history_file"

        echo "Withdrawal successful!"
      fi
    fi
  else
    echo "NID not found!"
  fi
}


# Function to display account information
display_account_info() {
  clear
  echo "Enter National ID (NID) number to display account information: "
  read nid_number

  # Check if the NID exists
  if grep -q "$nid_number" "$account_info_file"; then
    # Display account information
    awk -v nid="$nid_number" -F, '$3==nid {printf "Account Number: %s\nCustomer Name: %s\nNational ID (NID) Number: %s\nCurrent Balance: %s\n", $1, $2, $3, $4}' "$account_info_file"
  else
    echo "NID not found!"
  fi
}

# Function to display transaction history
display_transaction_history() {
  clear
  echo "Enter National ID (NID) number to display transaction history: "
  read nid_number

  # Check if the NID exists
  if grep -q "$nid_number" "$account_info_file"; then
    # Display transaction history for the given NID
    awk -v nid="$nid_number" -F, '$2==nid {printf "%s - %s %s %s\n", $1, $3, $4, $5}' "$transaction_history_file"
  else
    echo "NID not found!"
  fi
}

# Main function to display menu and handle user input
main() {
  while true; do
    clear
    echo "Bank Management System"
    echo "----------------------"
    echo "1. Create a new customer account"
    echo "2. Deposit"
    echo "3. Withdrawal"
    echo "4. Display account information"
    echo "5. Display transaction history"
    echo "6. Exit"
    read choice

    case $choice in
      1) new_account ;;
      2) deposit ;;
      3) withdrawal ;;
      4) display_account_info ;;
      5) display_transaction_history ;;
      6) exit ;;
      *) echo "Invalid choice!" ;;
    esac

    read -p "Press enter to continue..."
  done
}

# Call the main function to start the program
main

