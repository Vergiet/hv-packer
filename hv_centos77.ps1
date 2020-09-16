# Build images

# Get Start Time
$startDTM = (Get-Date)

# Variables
$template_file="./templates/hv_centos7_g2.json"
$var_file="./variables/variables_centos77.json"
$machine="CentOS 7.7 1908"
$packer_log=0

if ((Test-Path -Path "$template_file") -and (Test-Path -Path "$var_file")) {
  Write-Output "Template and var file found"
  Write-Output "Building: $machine"
  try {
    $env:PACKER_LOG=$packer_log
    packer validate -var-file="$var_file" "$template_file"
  }
  catch {
    Write-Output "Packer validation failed, exiting."
    exit (-1)
  }
  try {
    $env:PACKER_LOG=$packer_log
    packer --version
    packer build --force -var-file="$var_file" "$template_file"
  }
  catch {
    Write-Output "Packer build failed, exiting."
    exit (-1)
  }
}
else {
  Write-Output "Template or Var file not found - exiting"
  exit (-1)
}

$endDTM = (Get-Date)
Write-Host "[INFO]  - Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds" -ForegroundColor Yellow

#http://ftp.ps.pl/pub/Linux/CentOS/7/isos/x86_64/CentOS-7-x86_64-Everything-2003.iso
#DF6BD143D0A747A83FEBB1DC3F1293EBEF31AEC2

#http://mirror.webruimtehosting.nl/centos/7.8.2003/isos/x86_64/CentOS-7-x86_64-DVD-2003.iso
#AB6F6BAB124CD749A69AE63DC3B5FBFA4D0E52B5