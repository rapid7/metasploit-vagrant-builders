REM Prepare ruby default gemset to handle metasploit omnibus build
git clone https://github.com/rapid7/metasploit-omnibus
cd metasploit-omnibus
# git checkout update-support-for-ruby-3.1
gem install bundler -v2.2.3 --no-document && bundle install && bundle binstubs --all
cd ..
rm -rf metasploit-omnibus
