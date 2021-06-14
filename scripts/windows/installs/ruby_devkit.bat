set ChocolateyUrl64bitOverride=https://github.com/rapid7/metasploit-omnibus-cache/raw/7cad45e5886d0a9b3d587c86a65d66234986223a/DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe
choco install -y ruby2.devkit
setx PATH "%PATH%;C:\tools\DevKit2\bin"
cd C:\tools\DevKit2
echo "- C:\tools\ruby26" >> config.yml
C:\tools\ruby26\bin\ruby.exe dk.rb install --force
C:\tools\ruby26\bin\ridk.cmd install 3
refreshenv
