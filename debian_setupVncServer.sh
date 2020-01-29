#!/bin/bash

######################################
###Requires Sudo installation first###
######################################

#Execute me like this
#source <(curl -s "https://raw.githubusercontent.com/qwertycody/Debian_Server_Setup_Utilities/master/debian_setupVncServer.sh")

randpw(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-8};echo;}
sudo apt-get install -y tightvncserver xfce4

VNC_USERNAME="cody"
VNC_PASSWORD=$(randpw)

rm -Rf /home/$VNC_USERNAME/.vnc
mkdir /home/$VNC_USERNAME/.vnc
echo $VNC_PASSWORD | vncpasswd -f > /home/$VNC_USERNAME/.vnc/passwd
chown -R $VNC_USERNAME:$VNC_USERNAME /home/$VNC_USERNAME/.vnc
chmod 0600 /home/$VNC_USERNAME/.vnc/passwd

vncserver 

echo "Password for VNC is $VNC_PASSWORD"
echo "$VNC_PASSWORD" > ~/vnc_password.txt
vncserver -kill :1

mv ~/.vnc/xstartup ~/.vnc/xstartup.bak

echo "#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &" > ~/.vnc/xstartup

chmod +x ~/.vnc/xstartup

sudo sh -c "echo \"[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=$VNC_USERNAME
Group=$VNC_USERNAME
WorkingDirectory=/home/$VNC_USERNAME

PIDFile=/home/$VNC_USERNAME/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
\" > /etc/systemd/system/vncserver@.service"

sudo systemctl daemon-reload
sudo systemctl enable vncserver@1.service

vncserver -kill :1

sudo systemctl start vncserver@1
sudo systemctl status vncserver@1
