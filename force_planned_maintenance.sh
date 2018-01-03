#!/bin/bash
##############################################################################################################
#  ____                                      _       
# | __ )  __ _ _ __ _ __ __ _  ___ _   _  __| | __ _ 
# |  _ \ / _` | '__| '__/ _` |/ __| | | |/ _` |/ _` |
# | |_) | (_| | |  | | | (_| | (__| |_| | (_| | (_| |
# |____/ \__,_|_|  |_|  \__,_|\___|\__,_|\__,_|\__,_|
#                                                    
# Script to search for VM's that needs maintenance and then performs such maintenance
#
##############################################################################################################

# Input location 
echo -n "Enter resource group search string : "
stty_orig=`stty -g` # save original terminal setting.
read searchstring         # read the location
stty $stty_orig     # restore terminal setting.
if [ -z "$searchstring" ] 
then
    location="eastus2"
fi

for i in `az group list -o table | grep "$searchstring" | awk '{print $1}'`
do
    echo "Reviewing Resource Group $i"
    for j in `az vm list -g $i -o table | awk '{print $1}'`
    do
        if [ "$j" != "Name" -a ${j:0:1} != '-' ]
        then
            echo "Reviewing VM [$j]"
            result=`az vm get-instance-view  -g "$i" -n "$j" | grep 'isCustomerInitiatedMaintenanceAllowed' | grep 'true'`
            if [ ! -z "$result" ]
            then
                echo "--> Maintenance required for [$j]"
                az vm perform-maintenance "$i" "$j"
            fi
        fi
    done
done
