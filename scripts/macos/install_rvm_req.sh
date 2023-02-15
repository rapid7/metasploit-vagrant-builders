#!/bin/bash

su vagrant -c 'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB'
su vagrant -c '\curl -sSL https://get.rvm.io | bash -s stable --ruby'

su vagrant -c '/bin/bash -l -c "rvm install 2.5.3"'
su vagrant -c '/bin/bash -l -c "rvm use 2.5.3; gem install bundler -v2.1.4"'
