su vagrant -c "curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash"

su vagrant -c 'echo export PATH="/Users/vagrant/.pyenv/bin:$PATH" >> ~/.profile'
su vagrant -c 'echo eval "$(pyenv init -)" >> ~/.profile'
su vagrant -c 'echo eval "$(pyenv virtualenv-init -)" >> ~/.profile'

su vagrant -c '/bin/bash -l -c "pyenv install 2.7.13"'
