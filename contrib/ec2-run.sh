#!/bin/bash
#
# This script handles actually running the server for the setup
# generated by ec2.sh: it starts the Sirikata server via God for
# montoring and starts the lighttpd server.

DIR=`pwd`

# Generate our configuration
echo "SIRIKATA_ROOT = '${DIR}/sirikata.git'" > config.god.rb
echo "SPACE_PORT = 7777" >> config.god.rb
echo "SIRIKATA_UID = 'ubuntu'" >> config.god.rb
echo "SIRIKATA_MAX_MEMORY = 400.megabytes" >> config.god.rb

# Copy the configuration locally, getting our config script in there.
# Commenting out stop_timeout is currently required because Ubuntu's
# God doesn't support it.
sed \
    -e "s|/path/to/user/config.god.rb|config.god.rb|" \
    -e "s|w.stop_timeout|#w.stop_timeout|" \
    <sirikata.git/tools/space/space.god.rb >space.god.rb
# Run the space server god script
sudo /var/lib/gems/1.8/bin/god -c space.god.rb

# Run lighttpd as the web server
cd kataspace.git
# lighttpd on Ubuntu starts itself automatically, so stop it first
sudo /etc/init.d/lighttpd stop
# And then run our version
sudo ./externals/katajs/contrib/lighttpd.py 80 &
