#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#		      Bootstrap Config #
# (C)2017-2018 Mattijs Snepvangers	#		 pegasus.ict@gmail.com #
# License: MIT				#   Please keep my name in the credits #
################################################################################
# cfg ver: 0.2.2 ALPHA
# cfg build 20180819

declare -Ag CFG=(
    ### GENERAL SETTINGS #######################################################
    # Verbosity: 1=CRITICAL 2=ERROR 3=WARNING 4=VERBOSE 5=DEBUG
    [MAIN__VERBOSITY]=2
    [MAIN__REBOOT_TIME]="23:59"

    ### SYSTEM ROLE DEFINITIONS ################################################
    # CHOSEN_ROLE => BASIC | WS | SERVER | LXCHOST | HOOFDSERVER | POSEIDON |
    #                 CONTAINER
    [SYSTEM_ROLE__CHOSEN_ROLE]="POSEIDON"
    # CONTAINER_ROLE => BASIC | FIREWALL | HONEY | NAS | PXE | ROUTER | WEB | X11
    [SYSTEM_ROLE__CONTAINER_ROLE]=""
    ### EXTRA APPS #############################################################
    [ADD_EXTRA_APP__STARUML]=true
    [ADD_EXTRA_APP__GITKRAKEN]=true
)
################################################################################
	case "$CFG[SYSTEM_ROLE__CHOSEN_ROLE]" in
		"WS"|"ws"	)
						CFG[SYSTEM_ROLE__WS]=true			;
						CFG[SYSTEM_ROLE__BASIC]=true		;
						dbg_line "role=WS"	;;
		"POSEIDON"|"poseidon"	)
						CFG[SYSTEM_ROLE__BASIC]=true		;
						CFG[SYSTEM_ROLE__WS]=true			;
						CFG[SYSTEM_ROLE__SERVER]=true		;
						CFG[SYSTEM_ROLE__LXC_HOST]=true		;
						CFG[SYSTEM_ROLE__POSEIDON]=true		;
						CFG[SYSTEM_ROLE__NAS]=true			;
						dbg_line "role=POSEIDON"	;;
		"MAINSERVER"|"mainserver"	)
						CFG[SYSTEM_ROLE__BASIC]=true		;
						CFG[SYSTEM_ROLE__SERVER]=true		;
						CFG[SYSTEM_ROLE__MAIN_SERVER]=true	;
						CFG[SYSTEM_ROLE__LXC_HOST]=true		;
						dbg_line "role=MAIN_SERVER"	;;
		"CONTAINER"|"container"	)
						CFG[SYSTEM_ROLE__BASIC]=true		;
						CFG[SYSTEM_ROLE__SERVER]=true		;
						CFG[SYSTEM_ROLE__CONTAINER]=true	;
						dbg_line "role=CONTAINER"	;;
		*			)	critline "CRITICAL: Unknown system role, exiting...";
						exit 1;;
	esac

if [[ "$CFG[SYSTEM_ROLE__CHOSEN_ROLE]" == CONTAINER ]]
then
	case "$CFG[SYSTEM_ROLE__CONTAINER_ROLE]" in
		"NAS"|"nas"		)
						CFG[SYSTEM_ROLE__NAS]=true		;
						dbg_line "CONTAINER=NAS"		;;
		"WEB"|"web"		)
						CFG[SYSTEM_ROLE__NAS]=true		;
						CFG[SYSTEM_ROLE__WEB]=true		;
						dbg_line "CONTAINER=WEB"		;;
		"X11"|"x11"		)
						CFG[SYSTEM_ROLE__WS]=true		;
						dbg_line "CONTAINER=X11"		;;
		"PXE"|"pxe"		)
						CFG[SYSTEM_ROLE__PXE]=true		;
						dbg_line "CONTAINER=PXE"		;;
		"BASIC"|"basic"		)
						dbg_line "CONTAINER=BASIC"		;;
		"ROUTER"|"router"	)
						CFG[SYSTEM_ROLE__ROUTER]=true	;
						dbg_line "CONTAINER=ROUTER"		;;
		"HONEYPOT"|"honeypot"	)
						CFG[SYSTEM_ROLE__HONEY_POT]=true	;
						dbg_line "CONTAINER=HONEY POT"		;;
		*)	err_line "WARNING: Unknown containertype, selecting BASIC"	;;
	esac;

declare -g SOURCES_LIST	;	SOURCES_LIST=""
if [[ "$CFG[SYSTEM_ROLE__BASIC]" = true ]]
then
    SOURCES_LIST+=<<-EOT
    ### GetDeb http://www.getdeb.net
    deb http://archive.getdeb.net/ubuntu bionic-getdeb apps
    ### Syncthing https://syncthing.net/
    deb http://apt.syncthing.net/ syncthing release
    ### TeamViewer https://teamviewer.com
    deb http://linux.teamviewer.com/deb stable main
    deb http://linux.teamviewer.com/deb preview main
    ### Webmin http://www.webmin.com
    deb http://download.webmin.com/download/repository sarge contrib
    ### WebUpd8 http://www.webupd8.org/
    deb http://ppa.launchpad.net/nilarimogard/webupd8/ubuntu bionic main
    deb-src http://ppa.launchpad.net/nilarimogard/webupd8/ubuntu bionic main
EOT
fi
if [[ "$CFG[SYSTEM_ROLE__WS]" = true ]]
then
    SOURCES_LIST+=<<-EOT
    ### DropBox http://dropbox.com
    deb http://linux.dropbox.com/ubuntu/ bionic main
    ### GIMP https://launchpad.net/~otto-kesselgulasch/+archive/gimp
    deb http://ppa.launchpad.net/otto-kesselgulasch/gimp/ubuntu bionic main
    deb-src http://ppa.launchpad.net/otto-kesselgulasch/gimp/ubuntu bionic main
    ### Gnome3 https://launchpad.net/~gnome3-team/+archive/gnome3
    deb http://ppa.launchpad.net/gnome3-team/gnome3/ubuntu bionic main
    deb-src http://ppa.launchpad.net/gnome3-team/gnome3/ubuntu bionic main
    ### Google_Chrome="http://www.google.com/linuxrepositories/" "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"
    Google_Webdesigner="http://www.google.com/linuxrepositories/" "deb [arch=amd64] http://dl.google.com/linux/webdesigner/deb/ stable main"
    Highly_Explosive="https://launchpad.net/~dhor/+archive/myway" "deb http://ppa.launchpad.net/dhor/myway/ubuntu bionic main\ndeb-src http://ppa.launchpad.net/dhor/myway/ubuntu bionic main"
    Mega="https://mega.co.nz/" "deb http://mega.nz/linux/MEGAsync/xUbuntu_16.04/ ./"
    MKVToolnix="http://www.bunkus.org/videotools/mkvtoolnix/" "deb http://www.bunkus.org/ubuntu/bionic/ ./\ndeb-src http://www.bunkus.org/ubuntu/bionic/ ./"
    Opera="http://www.opera.com/" "deb http://deb.opera.com/opera/ stable non-free\ndeb http://deb.opera.com/opera-beta/ stable non-free"
    OwnCloud_Desktop="http://owncloud.org/" "deb http://download.opensuse.org/repositories/isv:/ownCloud:/community/xUbuntu_18.04/ /"
    VirtualBox="http://www.virtualbox.org" "deb http://download.virtualbox.org/virtualbox/debian bionic contrib"
    Wine="https://launchpad.net/~ubuntu-wine/+archive/ppa/" "deb http://ppa.launchpad.net/ubuntu-wine/ppa/ubuntu bionic main\ndeb-src http://ppa.launchpad.net/ubuntu-wine/ppa/ubuntu bionic main"
EOT
if [[ "$CFG[SYSTEM_ROLE__POSEIDON]" = true ]]
then
    SOURCES_LIST+=<<-EOT
EOT

if [[ "$CFG[SYSTEM_ROLE__SERVER]" = true ]]
then
    SOURCES_LIST+=<<-EOT
EOT

if [[ "$CFG[SYSTEM_ROLE__LXCHOST]" = true ]]
then
    SOURCES_LIST+=<<-EOT
EOT

if [[ "$CFG[SYSTEM_ROLE__MAINSERVER]" = true ]]
then
    SOURCES_LIST+=<<-EOT
EOT

if [[ "$CFG[SYSTEM_ROLE__CONTAINER]" = true ]]
then
    SOURCES_LIST+=<<-EOT
EOT

if [[ "$CFG[SYSTEM_ROLE__NAS]" = true ]]
then
    SOURCES_LIST+=<<-EOT
    ### Syncthing https://syncthing.net/
    deb http://apt.syncthing.net/ syncthing release
EOT


if [[ "$CFG[SYSTEM_ROLE__PXE]" = true ]]
then
    SOURCES_LIST+=<<-EOT
EOT

if [[ "$CFG[SYSTEM_ROLE__ROUTER]" = true ]]
then
    SOURCES_LIST+=<<-EOT
EOT

if [[ "$CFG[SYSTEM_ROLE__WEB]" = true ]]
then
    SOURCES_LIST+=<<-EOT
EOT

if [[ "$CFG[SYSTEM_ROLE__X11]" = true ]]
then
    SOURCES_LIST+=<<-EOT
EOT

    ################################################################################

# use: add_ppa_key METHOD URL [KEY]
# opt: METHOD: <wget|apt-key|aar>
    ### PPA_KEYS ###################################################################
if [[ "$CFG[SYSTEM_ROLE__BASIC]" = true ]]
then
    info_line "Adding TeamViewer PPA Key"
    add_ppa_key	"wget" "https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc"
    info_line "Adding GetDeb PPA Key"
    add_ppa_key	"wget" "http://archive.getdeb.net/getdeb-archive.key"
    info_line "Adding Webmin PPA Key"
    add_ppa_key	"wget" "http://www.webmin.com/jcameron-key.asc"
    info_line "Adding WebUpd8 PPA Key"
    add_ppa_key	"apt-key" "keyserver.ubuntu.com" "4C9D234C"
fi
if [[ "$CFG[SYSTEM_ROLE__WS]" = true ]]
then
    info_line "Adding VirtualBox PPA Key"
    add_ppa_key	"wget" "http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc"
    info_line "Adding FreeCad PPA Key"
    add_ppa_key	"aar" "ppa:freecad-maintainers/freecad-stable"
    info_line "Adding GIMP PPA Key"
    add_ppa_key	"apt-key" "keyserver.ubuntu.com" "614C4B38"
    info_line "Adding Gnome3 PPA Key"
    add_ppa_key	"apt-key" "keyserver.ubuntu.com" "3B1510FD"
    info_line "Adding Google PPA Key"
    add_ppa_key	"wget" "https://dl.google.com/linux/linux_signing_key.pub"
    info_line "Adding Highly_Explosive PPA Key"
    add_ppa_key	"apt-key" "keyserver.ubuntu.com" "93330B78"
    info_line "Adding MKVToolnix PPA Key"
    add_ppa_key	"wget" "http://www.bunkus.org/gpg-pub-moritzbunkus.txt"
    info_line "Adding Opera PPA Key"
    add_ppa_key	"wget" "http://deb.opera.com/archive.key"
    info_line "Adding OwnCloud_Desktop PPA Key"
    add_ppa_key	"wget" "http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_16.04/Release.key"
    info_line "Adding Wine PPA Key"
    add_ppa_key	"apt-key" "keyserver.ubuntu.com" "883E8688397576B6C509DF495A9A06AEF9CB8DB0"
fi
if [[ "$CFG[SYSTEM_ROLE__NAS]" = true ]]
then
    info_line "Adding Syncthing PPA Key"
    add_ppa_key	"wget" "https://syncthing.net/release-key.txt"
fi
### PACKAGES ###################################################################
declare APT_INST_LIST	;	APT_INST_LIST=""
if [[ "$CFG[SYSTEM_ROLE__BASIC]" = true ]]
then
    APT_INST_LIST=" mc trash-cli snapd git screen teamviewer"
fi
if [[ "$CFG[SYSTEM_ROLE__WS]" = true ]]
then
    APT_INST_LIST=" audacious google-chrome-stable google-webdesigner gparted lame playonlinux samba synaptic tilda winetricks wine-stable"
fi
if [[ "$CFG[SYSTEM_ROLE__SERVER]" = true ]]
then
    APT_INST_LIST=" openssh-server webmin"
fi
if [[ "$CFG[SYSTEM_ROLE__LXCHOST]" = true ]]
then
    APT_INST_LIST=" bridge-utils lxc lxcfs lxd lxd-tools xfsutils-linux"
fi
if [[ "$CFG[SYSTEM_ROLE__POSEIDON]" = true ]]
then
    APT_INST_LIST=" adb audacity calibre fastboot forensics-all forensics-extra forensics-extra-gui forensics-full fslint gadmin-proftpd geany geany-plugin-addons geany-plugin-git-changebar geany-plugin-lineoperations geany-plugin-miniscript geany-plugin-pairtaghighlight geany-plugin-projectorganize gprename masscan picard proftpd"
fi
if [[ "$CFG[SYSTEM_ROLE__MAINSERVER]" = true ]]
then
    APT_INST_LIST=" apt-cacher-ng"
fi
if [[ "$CFG[SYSTEM_ROLE__CONTAINER]" = true ]]
then
    APT_INST_LIST=""
fi
if [[ "$CFG[SYSTEM_ROLE__FIREWALL]" = true ]]
then
    APT_INST_LIST=""
fi
if [[ "$CFG[SYSTEM_ROLE__NAS]" = true ]]
then
    APT_INST_LIST=" nfsd proftpd samba"
fi
if [[ "$CFG[SYSTEM_ROLE__PXE]" = true ]]
then
    APT_INST_LIST=" atftpd"
fi
if [[ "$CFG[SYSTEM_ROLE__ROUTER]" = true ]]
then
    APT_INST_LIST=" bridge-utils ufw"
fi
if [[ "$CFG[SYSTEM_ROLE__WEB]" = true ]]
then
    APT_INST_LIST=" apache2 mysql-server mytop phpmyadmin proftpd php-cli"
fi
if [[ "$CFG[SYSTEM_ROLE__X11]" = true ]]
then
    APT_INST_LIST=""
fi
info_line "installing $APT_INST_LIST"
apt_inst "$APT_INST_LIST"
### EXTRA SOFTWARE #############################################################
if [[ "$[ADD_EXTRA_APP__STARUML]" = true ]]
then
    info_line "Installing StarUML"
    download "http://nl.archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb"
    install libgcrypt11_1.5.3-2ubuntu4.5_amd64.deb
    download "http://staruml.io/download/releases/StarUML-3.0.2-x86_64.AppImage"
    install StarUML-v2.8.0-64-bit.deb

fi
if [[ "$[ADD_EXTRA_APP__GITKRAKEN]" = true ]]
then
    install "https://release.gitkraken.com/linux/gitkraken-amd64.deb"


cr_sec_line "Installing GitKraken"
  download "https://release.gitkraken.com/linux/gitkraken-amd64.deb"
  install gitkraken-amd64.deb
fi
rm *.deb 2>&1 | dbg_line


	################################################################################

	[GARBAGE]
	################################################################################
	TMP_AGE=2
	GARBAGE_AGE=7
	LOG_AGE=30
	################################################################################

)
