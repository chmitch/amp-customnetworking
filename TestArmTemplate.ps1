#Login-AzureRmAccount

#You'll need to change this to be the name of your subscription
$subscription = "Microsoft Azure Internal Consumption"

#this prefix is used to help make names of vms storage accounts etc unique.  Keep if 5 characters or less.
$envPrefixName = "cgmtet58" 
$rgname = $envPrefixName + "rg"

$location = "East US"
$virtualNetworkName = $envPrefixName + "vnet"
$virtualNetworkExistingRGName = $rgname
$virtualNetworkAddressPrefix = "10.1.0.0/23"
$vnetNewOrExisting = "new"
$publicSubnetPrefix = "10.1.0.0/24"
$publicSubnetName = "public-subnet"
$privateSubnetPrefix = "10.1.1.0/24"
$privateSubnetName = "private-subnet"
#$subnetStartAddress = "10.1.0.1"
$adminUsername = "tetadmin"
#note put a real password in here
$adminPassword = "P@ss0wrd!!!" | ConvertTo-SecureString -AsPlainText -Force     
$sshPublicKey = ""
$authenticationType = "password"
$vmName = $envPrefixName + "orch"
$newStorageAccountName = $envPrefixName + "stor"
$storageAccountType = "Standard_LRS"
$storageAccountNewOrExisting ="new"
$storageAccountExistingRG = $rgname
$publicIPAddressName = $envPrefixName + "pubip"
$publicIPDnsName =  $envPrefixName + "dns"
$publicIPNewOrExisting = "new"
$publicIPExistingRGName = ""
$baseUrl = "https://raw.githubusercontent.com/chmitch/amp-customnetworking/master" 
$vmSize = "Standard_DS3_v2"

#-TemplateUri https://raw.githubusercontent.com/chmitch/tetration/master/mainTemplate.json `
#-TemplateFile C:\projects\tetration\mainTemplate.json `
New-AzureRmResourceGroup -Name $rgname -Location $location
    
New-AzureRmResourceGroupDeployment `
    -ResourceGroupName $rgname  `
    -DeploymentDebugLogLevel All `
-TemplateFile C:\projects\amp-customnetworking\mainTemplate.json `
    -location $location `
    -virtualNetworkName $virtualNetworkName `
    -virtualNetworkExistingRGName $virtualNetworkExistingRGName `
    -vnetNewOrExisting $vnetNewOrExisting `
    -publicSubnetPrefix $publicSubnetPrefix `
    -publicSubnetName $publicSubnetName `
    -privateSubnetPrefix $privateSubnetPrefix `
    -privateSubnetName $privateSubnetName `
    -adminUsername $adminUsername `
    -newStorageAccountName $newStorageAccountName `
    -storageAccountType $storageAccountType `
    -storageAccountNewOrExisting $storageAccountNewOrExisting `
    -storageAccountExistingRG $rgname `
    -authenticationType $authenticationType `
    -publicIPAddressName $publicIPAddressName `
    -publicIPDnsName $publicIPDnsName `
    -publicIPNewOrExisting $publicIPNewOrExisting `
    -publicIPExistingRGName $publicIPExistingRGName `
    -vmSize $vmSize -artifactsBaseUrl $baseUrl -adminPassword $adminPassword -uniqueNamePrefix $envPrefixName
    