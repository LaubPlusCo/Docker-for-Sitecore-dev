param(
	[string]$KeystoreFile = 'data\solr-ssl.keystore.jks',
	[string]$KeystorePassword = 'secret',
	[string]$SolrDomain = 'localhost',
	[switch]$Clobber
)

$ErrorActionPreference = 'Stop'

### PARAM VALIDATION
if($KeystorePassword -ne 'secret') {
	Write-Error 'The keystore password must be "secret", because Solr apparently ignores the parameter'
}

if((Test-Path $KeystoreFile)) {
	if($Clobber) {
		Write-Host "Removing $KeystoreFile..."
		Remove-Item $KeystoreFile
	} else {
		$KeystorePath = Resolve-Path $KeystoreFile
		Write-Error "Keystore file $KeystorePath already existed. To regenerate it, pass -Clobber."
	}
}

$P12Path = [IO.Path]::ChangeExtension($KeystoreFile, 'p12')
if((Test-Path $P12Path)) {
	if($Clobber) {
		Write-Host "Removing $P12Path..."
		Remove-Item $P12Path
	} else {
		$P12Path = Resolve-Path $P12Path
		Write-Error "Keystore file $P12Path already existed. To regenerate it, pass -Clobber."
	}
}

try {
	$keytool = (Get-Command 'keytool.exe').Source
} catch {
	$keytool = Read-Host "keytool.exe not on path. Enter path to keytool (found in JRE bin folder)"

	if([string]::IsNullOrEmpty($keytool) -or -not (Test-Path $keytool)) {
		Write-Error "Keytool path was invalid."
	}
}

### DOING STUFF

Write-Host ''
Write-Host 'Generating JKS keystore...'
& $keytool -genkeypair -alias solr-ssl -keyalg RSA -keysize 2048 -keypass $KeystorePassword -storepass $KeystorePassword -validity 9999 -keystore $KeystoreFile -ext SAN=DNS:$SolrDomain,IP:127.0.0.1 -dname "CN=$SolrDomain, OU=Organizational Unit, O=Organization, L=Location, ST=State, C=Country"

Write-Host ''
Write-Host 'Generating .p12 to import to Windows...'
& $keytool -importkeystore -srckeystore $KeystoreFile -destkeystore $P12Path -srcstoretype jks -deststoretype pkcs12 -srcstorepass $KeystorePassword -deststorepass $KeystorePassword

Write-Host ''
Write-Host 'Trusting generated SSL certificate...'
$secureStringKeystorePassword = ConvertTo-SecureString -String $KeystorePassword -Force -AsPlainText
$root = Import-PfxCertificate -FilePath $P12Path -Password $secureStringKeystorePassword -CertStoreLocation Cert:\LocalMachine\Root
Write-Host 'SSL certificate is now locally trusted. (added as root CA)'