#!/bin/bash

set -euxo pipefail

su vagrant -c 'export PATH="$(/usr/local/Homebrew/bin/brew --prefix gpg)/bin:$PATH"; export PATH="$(/usr/local/Homebrew/bin/brew --prefix coreutils)/bin:$PATH"; which gpg; which sha256sum; curl -o mpapis.asc -sSL https://rvm.io/mpapis.asc && echo "08f64631c598cbe4398c5850725c8e6ab60dc5d86b6214e069d7ced1d546043b  mpapis.asc" | sha256sum -c && gpg --import ./mpapis.asc; rm mpapis.asc'
su vagrant -c 'export PATH="$(/usr/local/Homebrew/bin/brew --prefix gpg)/bin:$PATH"; export PATH="$(/usr/local/Homebrew/bin/brew --prefix coreutils)/bin:$PATH"; which gpg; which sha256sum; curl -o pkuczynski.asc -sSL https://rvm.io/pkuczynski.asc && echo "d33ce5907fe28e6938feab7f63a9ef8a26a565878b1ad5bce063a86019aeaf77  pkuczynski.asc" | sha256sum -c && gpg --import ./pkuczynski.asc; rm pkuczynski.asc'
su vagrant -c 'export PATH="$(/usr/local/Homebrew/bin/brew --prefix gpg)/bin:$PATH"; \curl -sSL https://get.rvm.io | bash -s stable'

# For now build Ruby 3.0 with OpenSSL@1.1; it can be bumped to OpenSSL@3.x for Ruby 3.1+
rvm_install='
set -x
export PATH="$(brew --prefix openssl@1.1)/bin:$PATH";
export LDFLAGS="-L$(brew --prefix openssl@1.1)/lib";
export CPPFLAGS="-I$(brew --prefix openssl@1.1)/include";
export PKG_CONFIG_PATH="$(brew --prefix openssl@1.1)/lib/pkgconfig";
set +x
rvm reinstall 3.0.6
'
su vagrant -c "/bin/bash -l -c '$rvm_install'"
su vagrant -c '/bin/bash -l -c "rvm use 3.0.6; gem install bundler -v2.2.3"'
