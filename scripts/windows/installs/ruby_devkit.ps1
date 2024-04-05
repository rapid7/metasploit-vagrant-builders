# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

cd C:\vagrant\resources\windows\ruby_devkit_runtime
tar -cvf ../ruby_devkit_runtime.tar .
cd ..
tar -C C:\tools\ruby30\lib\ruby\site_ruby\3.0.0 -xvf ruby_devkit_runtime.tar
# Install option 3 - the msys2 and mingw development toolchain
C:\tools\ruby30\bin\ridk.cmd install 3
refreshenv
