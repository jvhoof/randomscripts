<#
.Synopsis
This script will recreate a Azure VM when you still have the OSDisk, Network Interface available.

.Description

#>

# Configure the following variables to get started
$location = "West Europe"
$resourceGroupName = "JVH11"
$vmName = "JVH11-VM-NGF" 
$vmSize = "Standard_F1s"
$networkInterfaceName = "jvh11-vm-ngf331"
$osDiskName = "JVH11-VM-NGF_OsDisk_1_bc6c1d4a1cfb4e99a75e03dff618460d"


# Create a new vm object with the required size and name
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
# Assign the plan (Azure Marketplace image) of the original os disk
$vm.Plan = @{'name'= "byol"; 'publisher'= 'barracudanetworks'; 'product' = "barracuda-ng-firewall"}

# Retrieve and assign the still existing network interface and public ip
$ifc = Get-AzureRmNetworkInterface -Name $networkInterfaceName -ResourceGroup $resourceGroupName
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $ifc.id -ErrorAction Stop -Primary

# Retrieve and assign the still existing osdisk
$disk = Get-AzureRmDisk -DiskName $osDiskName -ResourceGroup $resourceGroupName
$vm = Set-AzureRmVMOSDisk -VM $vm -ManagedDiskId $disk.id -CreateOption Attach -Linux

# Recreate the VM based on the above attributes
New-AzureRmVM -VM $vm -ResourceGroup $resourceGroupName -Location $location