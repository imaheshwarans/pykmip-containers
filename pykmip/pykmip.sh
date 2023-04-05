#!/bin/bash
HOME_DIR=$(pwd)

echo "Installing PYKMIP SERVER..."

COMPONENT_NAME=pykmip
SERVICE_USERNAME=pykmip
PRODUCT_HOME=/opt/$COMPONENT_NAME
PYKMIP_PATH=/etc/$SERVICE_USERNAME
POLICIES_PATH=$PYKMIP_PATH/policies
LOG_PATH=/var/log/$COMPONENT_NAME


dnf -qy install python3-pip vim-common wget || exit 1
ln -s /usr/bin/python3 /usr/bin/python  > /dev/null 2>&1
wget https://bootstrap.pypa.io/pip/3.6/get-pip.py
/usr/bin/python3 get-pip.py
ln -s /usr/bin/pip3 /usr/bin/pip  > /dev/null 2>&1 
pip3 install setuptools setuptools-rust pykmip==0.9.1 || exit 1

echo "Setting up PYKMIP Linux User..."
id -u $SERVICE_USERNAME 2> /dev/null || useradd --comment "PYKMIP SERVER" --home $PRODUCT_HOME --shell /bin/false $SERVICE_USERNAME

# Create logging dir in /var/log
mkdir -p $LOG_PATH 
if [ $? -ne 0 ]; then
	echo "${red} Cannot create directory: $LOG_PATH"
	exit 1
fi
chown $SERVICE_USERNAME:$SERVICE_USERNAME $LOG_PATH && chmod 755 $LOG_PATH

# Create pykmip and policies directory
mkdir -p $POLICIES_PATH 
if [ $? -ne 0 ]; then
	echo "${red} Cannot create directory: $POLICIES_PATH"
	exit 1
fi
chown $SERVICE_USERNAME:$SERVICE_USERNAME $POLICIES_PATH && chmod 755 $POLICIES_PATH
chown $SERVICE_USERNAME:$SERVICE_USERNAME $PYKMIP_PATH && chmod 755 $PYKMIP_PATH

# Create Product Home directory
mkdir -p $PRODUCT_HOME
if [ $? -ne 0 ]; then
	echo "${red} Cannot create directory: $PRODUCT_HOME"
	exit 1
fi
chmod 755 $PRODUCT_HOME

# Copy scipts/config files to pykmip directory
cp -pf ./root/pykmip/create_certificates.py $PYKMIP_PATH 
cp -pf ./root/pykmip/run_server.py $PYKMIP_PATH
cp -pf ./root/pykmip/server.conf $PYKMIP_PATH

# Run certificate script to generate certificates
cd $PYKMIP_PATH
python3 create_certificates.py 127.0.0.1
if [ $? -ne 0 ]; then
	echo "${red} Create Certificates failed"
	exit 1
fi
chown $SERVICE_USERNAME:$SERVICE_USERNAME $PYKMIP_PATH/* && chmod 644 $PYKMIP_PATH/*

ls $PYKMIP_PATH

cd $HOME_DIR

/usr/bin/python3 /etc/pykmip/run_server.py