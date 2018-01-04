#!/bin/bash
##############################################################################################################
#                                                    
# Script to search for Azure VM's that need maintenance and then performs such maintenance
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
    #echo "Reviewing Resource Group $i"
    for j in `az vm list -g $i -o table | awk '{print $1}'`
    do
        if [ "$j" != "Name" -a ${j:0:1} != '-' ]
        then
            #echo "Reviewing VM [$j]"
            result=`az vm get-instance-view  -g "$i" -n "$j" | grep 'isCustomerInitiatedMaintenanceAllowed' | grep 'true'`
            if [ ! -z "$result" ]
            then
                echo "--> Maintenance required for [$j]"
                #az vm perform-maintenance "$i" "$j"
            fi
        fi
    done
done
