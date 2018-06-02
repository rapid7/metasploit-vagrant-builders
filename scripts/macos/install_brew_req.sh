#!/bin/bash

su vagrant -c 'echo "\n" | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'

su vagrant -c '/bin/bash -l -c "brew install coreutils m4 automake mingw-w64 gpg"'


