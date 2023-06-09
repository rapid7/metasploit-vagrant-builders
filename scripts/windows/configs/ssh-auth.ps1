# vagrant public key or locally provided override
if (Test-Path -Path C:\vagrant\resources\authorized_keys -PathType Leaf) {
  copy C:\vagrant\resources\authorized_keys C:\Users\vagrant\.ssh\authorized_keys
} else {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub', 'C:\Users\vagrant\.ssh\authorized_keys')
}
