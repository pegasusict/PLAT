#!/bin/bash
################################################################################
# Pegasus' Linux Administration Tools	#				      Bootstrap Config #
# (C)2017-2018 Mattijs Snepvangers		#				 pegasus.ict@gmail.com #
# License: MIT							#   Please keep my name in the credits #
################################################################################
# cfg ver: 0.0.0 PRE-ALPHA
# cfg build 20180812

declare -Ag CFG=(
	### GENERAL SETTINGS #######################################################
	# Verbosity: 1=CRITICAL 2=ERROR 3=WARNING 4=VERBOSE 5=DEBUG
	[MAIN__VERBOSITY]=2
	[MAIN__REBOOT_TIME]="23:59"

	### SYSTEM ROLE DEFINITIONS ################################################
    # CHOSEN_ROLE => BASIC | WS | SERVER | LXCHOST | HOOFDSERVER | POSEIDON | CONTAINER
    [SYSTEM_ROLE__CHOSEN_ROLE]="POSEIDON"
    # CONTAINER_ROLE => BASIC | FIREWALL | HONEY | NAS | PXE | ROUTER | WEB | X11
    [SYSTEM_ROLE__CONTAINER_ROLE]=""
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
		"HOOFDSERVER"|"hoofdserver"	)
						CFG[SYSTEM_ROLE__BASIC]=true		;
						CFG[SYSTEM_ROLE__SERVER]=true		;
						CFG[SYSTEM_ROLE__MAIN_SERVER]=true	;
						CFG[SYSTEM_ROLE__LXC_HOST]=true		;
						dbg_line "role=HOOFDSERVER"	;;
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
		*)	err_line "WARNING: Unknown containertype, selecting BASIC"	;;
	esac;


if [[ CFG[SYSTEM_ROLE__BASIC] = true ]]
then
	SOURCES_LIST=<<-EOT
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
if [[ CFG[SYSTEM_ROLE__WS] = true ]]
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
	[PPA_LIST_POSEIDON]
	[PPA_LIST_SERVER]
	[PPA_LIST_LXCHOST]
	[PPA_LIST_MAINSERVER]
	[PPA_LIST_CONTAINER]
	[PPA_LIST_NAS]
	Syncthing="https://syncthing.net/" "deb http://apt.syncthing.net/ syncthing release"
	[PPA_LIST_PXE]
	[PPA_LIST_ROUTER]
	[PPA_LIST_WEB]
	[PPA_LIST_X11]
	################################################################################


	### PPA_KEYS ###################################################################
	[PPA_KEYS_BASIC]
	TeamViewer="wget" "https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc"
	GetDeb="wget" "http://archive.getdeb.net/getdeb-archive.key"
	Webmin="wget" "http://www.webmin.com/jcameron-key.asc"
	WebUpd8="apt-key" "keyserver.ubuntu.com" "4C9D234C"
	[PPA_KEYS_WS]
	VirtualBox="wget" "http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc"
	FreeCad="aar" "ppa:freecad-maintainers/freecad-stable"
	GIMP="apt-key" "keyserver.ubuntu.com" "614C4B38"
	Gnome3="apt-key" "keyserver.ubuntu.com" "3B1510FD"
	Google="wget" "https://dl.google.com/linux/linux_signing_key.pub"
	Highly_Explosive="apt-key" "keyserver.ubuntu.com" "93330B78"
	MKVToolnix="wget" "http://www.bunkus.org/gpg-pub-moritzbunkus.txt"
	Opera="wget" "http://deb.opera.com/archive.key"
	OwnCloud_Desktop="wget" "http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_16.04/Release.key"
	Wine="apt-key" "keyserver.ubuntu.com" "883E8688397576B6C509DF495A9A06AEF9CB8DB0"
	[PPA_KEYS_NAS]
	Syncthing="wget" "https://syncthing.net/release-key.txt"
	################################################################################

	[PACKAGES]
	### PACKAGES ###################################################################
	BASIC="mc trash-cli snapd git screen teamviewer"
	WS="audacious google-chrome-stable google-webdesigner gparted lame playonlinux samba synaptic tilda winetricks wine-stable"
	SERVER="openssh-server webmin"
	LXCHOST="bridge-utils lxc lxcfs lxd lxd-tools xfsutils-linux"
	POSEIDON="adb audacity calibre fastboot forensics-all forensics-extra forensics-extra-gui forensics-full fslint gadmin-proftpd geany geany-plugin-addons geany-plugin-git-changebar geany-plugin-lineoperations geany-plugin-miniscript geany-plugin-pairtaghighlight geany-plugin-projectorganize gprename masscan picard proftpd"
	MAINSERVER="apt-cacher-ng"
	CONTAINER=""
	FIREWALL=
	NAS="nfsd proftpd samba"
	PXE="atftpd"
	ROUTER="bridge-utils ufw"
	WEB="apache2 mysql-server mytop phpmyadmin proftpd php-cli"
	X11=""
	################################################################################

	[XTRA_SOFTWARE]
	### EXTRA SOFTWARE #############################################################
	STARUML=""
	GITKRAKEN="https://release.gitkraken.com/linux/gitkraken-amd64.deb"
	################################################################################

	[GARBAGE]
	################################################################################
	TMP_AGE=2
	GARBAGE_AGE=7
	LOG_AGE=30
	################################################################################

)
