#!/bin/bash

echo -e "Take back ownership of TPM..."
echo -e "Take back TPM in tpm_manager_client..."
tpm_manager_client take_ownership
sleep 1

echo -e "Remove Firmware Management Parameters..."
echo -e "> Remove FWMP in cryptohome..."
cryptohome --action=set_firmware_management_parameters --flags=0 >/dev/null 2>&1
echo -e "> Remove FWMP in device_management_client..."
device_management_client --action=remove_firmware_management_parameters
echo -e "> Set FWMP flags to 0..."
device_management_client --action=set_firmware_management_parameters --flags=0x0000
sleep 1

echo -e "Unblocking developer mode..."
echo -e "> Remove devmode block in VPD..."
vpd -i RW_VPD -s block_devmode=0
echo -e "> Remove devmode block in crossystem..."
crossystem block_devmode=0
sleep 1

echo -e "Done!"
sleep 1
echo -e "This is just modmium's fwmp.sh but I added more shit to it."
echo -e "- wato"
