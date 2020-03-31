choco install -y ruby --version 2.6.5.1
refreshenv
choco install -y ruby2.devkit
setx PATH "%PATH%;C:\tools\DevKit2\bin"
refreshenv
cd C:\tools\DevKit2
echo "- C:\tools\ruby26" >> config.yml
ruby dk.rb install --force
ridk install 3
refreshenv
