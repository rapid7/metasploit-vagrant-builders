#!/bin/bash

su vagrant -c 'echo "\n" | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"'

su vagrant -c '/bin/bash -l -c "brew install coreutils m4 automake mingw-w64 gpg ldid"'


