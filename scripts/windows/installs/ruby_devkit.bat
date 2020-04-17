choco install -y ruby2.devkit
setx PATH "%PATH%;C:\tools\DevKit2\bin"
cd C:\tools\DevKit2
echo "- C:\tools\ruby26" >> config.yml
C:\tools\ruby26\bin\ruby.exe dk.rb install --force
C:\tools\ruby26\bin\ridk.cmd install 3
refreshenv
