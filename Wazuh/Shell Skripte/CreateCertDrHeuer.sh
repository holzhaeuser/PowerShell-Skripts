openssl req -newkey rsa:2048  -nodes -sha256 -keyout \wazuh.key -out \wazuh.csr -config \san.conf

san.conf:

[ req ]

default_bits           = 2048

distinguished_name     = req_distinguished_name

req_extensions         = req_ext

 

[ req_distinguished_name ]

countryName            = Country Name (2 letter code)

stateOrProvinceName    = State or Province Name (full name)

localityName           = Locality Name (eg, city)

organizationName       = Organization Name (eg, company)

commonName             = Common Name (e.g. server FQDN or YOUR name)

 

# Optionally, specify some defaults.
countryName_default           = DE
stateOrProvinceName_default   = NRW
localityName_default           = BO
0.organizationName_default     = It-Akademie Dr.Heuer GmbH
organizationalUnitName_default = IT
emailAddress_default           = office@drheuer.de

 

[ req_ext ]

subjectAltName = @alt_names

 

[alt_names]

DNS.1   = srv-wazuh

DNS.2   = srv-wazuh.drheuer.net

IP.1	= 192.168.11.150