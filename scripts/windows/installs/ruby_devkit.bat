cd C:\vagrant\resources\windows\ruby_devkit_runtime
tar -cvf ../ruby_devkit_runtime.tar .
cd ..
tar -C C:\tools\ruby26\lib\ruby\site_ruby\2.6.0 -xvf ruby_devkit_runtime.tar
C:\tools\ruby26\bin\ridk.cmd install 3
refreshenv
