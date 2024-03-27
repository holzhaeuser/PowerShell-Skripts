
for ($i = 0
  $i -lt 10
  $i++){
    Get-Certificate -Template DC02-CA_Computer -CertStoreLocation cert:\LocalMachine\My
}