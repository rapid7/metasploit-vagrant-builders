choco install -y ruby2.devkit
setx PATH "%PATH%;C:\tools\DevKit2\bin"
cd C:\tools\DevKit2
echo "- C:\tools\ruby24" >> config.yml
ruby dk.rb install --force
ridk install 3
refreshenv
