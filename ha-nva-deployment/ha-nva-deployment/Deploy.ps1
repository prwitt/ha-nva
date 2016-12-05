#
# Deploy_ReferenceArchitecture.ps1
#
param(
  [Parameter(Mandatory=$true)]
  $SubscriptionId,
  [Parameter(Mandatory=$false)]
  $Location = "West US 2",
  [Parameter(Mandatory=$false)]
  $ResourceGroupName = "ha-nva-rg",
  [Parameter(Mandatory=$false)]
  [ValidateSet("All","Infrastructure","Docker")]
  $Mode = "Docker"
)

$ErrorActionPreference = "Stop"

$buildingBlocksRootUriString = $env:TEMPLATE_ROOT_URI
if ($buildingBlocksRootUriString -eq $null) {
  $buildingBlocksRootUriString = "https://raw.githubusercontent.com/mspnp/template-building-blocks/master/"
}

if (![System.Uri]::IsWellFormedUriString($buildingBlocksRootUriString, [System.UriKind]::Absolute)) {
  throw "Invalid value for TEMPLATE_ROOT_URI: $env:TEMPLATE_ROOT_URI"
}

Write-Host
Write-Host "Using $buildingBlocksRootUriString to locate templates"
Write-Host

$templateRootUri = New-Object System.Uri -ArgumentList @($buildingBlocksRootUriString)
$virtualNetworkTemplate = New-Object System.Uri -ArgumentList @($templateRootUri, "templates/buildingBlocks/vnet-n-subnet/azuredeploy.json")
$loadBalancerTemplate = New-Object System.Uri -ArgumentList @($templateRootUri, "templates/buildingBlocks/loadBalancer-backend-n-vm/azuredeploy.json")
$multiVMsTemplate = New-Object System.Uri -ArgumentList @($templateRootUri, "templates/buildingBlocks/multi-vm-n-nic-m-storage/azuredeploy.json")
$udrTemplate = New-Object System.Uri -ArgumentList @($templateRootUri, "templates/buildingBlocks/userDefinedRoutes/azuredeploy.json")

$virtualNetworkParametersFile = [System.IO.Path]::Combine($PSScriptRoot, "parameters\ha-nva-vnet.parameters.json")
$webSubnetLoadBalancerAndVMsParametersFile = [System.IO.Path]::Combine($PSScriptRoot, "parameters\ha-nva-web.parameters.json")
$mgmtSubnetVMsParametersFile = [System.IO.Path]::Combine($PSScriptRoot, "parameters\ha-nva-mgmt.parameters.json")
$nva1ParametersFile = [System.IO.Path]::Combine($PSScriptRoot, "parameters\ha-nva1.parameters.json")
$nva2ParametersFile = [System.IO.Path]::Combine($PSScriptRoot, "parameters\ha-nva2.parameters.json")
$zooParametersFile = [System.IO.Path]::Combine($PSScriptRoot, "parameters\ha-nva-zoo.parameters.json")
$udrParametersFile = [System.IO.Path]::Combine($PSScriptRoot, "parameters\ha-nva-udr.parameters.json")

# Login to Azure and select your subscription
Login-AzureRmAccount -SubscriptionId $SubscriptionId | Out-Null

if($Mode -eq "All" -Or $Mode -eq "Infrastructure"){
	# Create the resource group
	$networkResourceGroup = New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location

	Write-Host "Deploying virtual network..."
	#New-AzureRmResourceGroupDeployment -Name "ra-vnet-deployment" -ResourceGroupName $networkResourceGroup.ResourceGroupName `
	#	-TemplateUri $virtualNetworkTemplate.AbsoluteUri -TemplateParameterFile $virtualNetworkParametersFile

	Write-Host "Deploying load balancer and virtual machines in web subnet..."
	#New-AzureRmResourceGroupDeployment -Name "ra-web-lb-vms-deployment" -ResourceGroupName $networkResourceGroup.ResourceGroupName `
	#	-TemplateUri $loadBalancerTemplate.AbsoluteUri -TemplateParameterFile $webSubnetLoadBalancerAndVMsParametersFile

	Write-Host "Deploying jumpbox in mgmt subnet..."
	#New-AzureRmResourceGroupDeployment -Name "ra-mgmt-vms-deployment" -ResourceGroupName $networkResourceGroup.ResourceGroupName `
	#	-TemplateUri $multiVMsTemplate.AbsoluteUri -TemplateParameterFile $mgmtSubnetVMsParametersFile
	
	Write-Host "Deploying nva1..."
	New-AzureRmResourceGroupDeployment -Name "ra-nva1-deployment" -ResourceGroupName $networkResourceGroup.ResourceGroupName `
		-TemplateUri $multiVMsTemplate.AbsoluteUri -TemplateParameterFile $nva1ParametersFile

	Write-Host "Deploying nva2..."
	New-AzureRmResourceGroupDeployment -Name "ra-nva1-deployment" -ResourceGroupName $networkResourceGroup.ResourceGroupName `
		-TemplateUri $multiVMsTemplate.AbsoluteUri -TemplateParameterFile $nva2ParametersFile


	Write-Host "Deploying udr..."
	#New-AzureRmResourceGroupDeployment -Name "ra-udr-deployment" -ResourceGroupName $networkResourceGroup.ResourceGroupName `
	#	-TemplateUri $udrTemplate.AbsoluteUri -TemplateParameterFile $udrParametersFile
}

if($Mode -eq "All" -Or $Mode -eq "Docker"){
	Write-Host "Deploying docker vms..."
	New-AzureRmResourceGroupDeployment -Name "ra-mgmt-vms-deployment" -ResourceGroupName $networkResourceGroup.ResourceGroupName `
		-TemplateUri $multiVMsTemplate.AbsoluteUri -TemplateParameterFile $zooParametersFile
}