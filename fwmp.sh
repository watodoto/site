#!/bin/bash
# now with 1 billion times more skid

echo -e
echo -e "----- Take back ownership of TPM -----"
echo -e "> Take back TPM in tpm_manager_client..."
tpm_manager_client take_ownership >/dev/null
sleep 1
echo -e "--------------------------------------"
echo -e

echo -e "------------ Remove FWMP -------------"
echo -e "> Remove FWMP in cryptohome..."
cryptohome --action=set_firmware_management_parameters --flags=0 >/dev/null
echo -e "> Remove FWMP in device_management_client..."
device_management_client --action=remove_firmware_management_parameters >/dev/null
echo -e "> Set FWMP flags to 0..."
device_management_client --action=set_firmware_management_parameters --flags=0x0000 >/dev/null
echo -e "--------------------------------------"
sleep 1
echo -e

echo -e "----- Unblocking developer mode ------"
echo -e "> Remove devmode block in VPD..."
vpd -i RW_VPD -s block_devmode=0 >/dev/null
echo -e "> Remove devmode block in crossystem..."
crossystem block_devmode=0 >/dev/null
echo -e "--------------------------------------"
sleep 1
echo -e

echo -e "Done!"
sleep 1
echo -e "This is just modmium's fwmp.sh but I added more shit to it."
echo -e "- wato"
