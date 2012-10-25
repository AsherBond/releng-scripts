# All values must be set in order to do installation

# Public server for rsync
REMOTE_SERVER=user@remote.server.com

# Private key for public server
PRIVATE_KEY=~/.ssh/id_rsa

# GNUPGHOME path for keys
KEY_PATH=~/.gnupg

# Virtualenv for running arado scripts
PYTHON_VIRTENV=/opt/nightly/aradopy

# Location of arado scripts
ARADO_HOME=/opt/nightly/arado

# Location where nightly scripts are installed
NIGHTLY_PATH=/opt/nightly/build

# Location to log messages
LOGFILE=/var/log/promote-nightly.log

# Email address for notifications
NOTIFY_ADDRESS=some@address.com

