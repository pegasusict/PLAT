#!/bin/bash -p
############################################################################
# Pegasus' Linux Administration Tools #				  Pegasus' PLAT Tester #
# (C)2017-2018 Mattijs Snepvangers	  #				 pegasus.ict@gmail.com #
# License: MIT						  #	Please keep my name in the credits #
############################################################################

#######################################################
# PROGRAM_SUITE="Pegasus' Linux Administration Tools" #
# SCRIPT_TITLE="Function Tester Script"				  #
# MAINTAINER="Mattijs Snepvangers"					  #
# MAINTAINER_EMAIL="pegasus.ict@gmail.com"			  #
# VERSION_MAJOR=0									  #
# VERSION_MINOR=0									  #
# VERSION_PATCH=0									  #
# VERSION_STATE="PRE-ALPHA"							  #
# VERSION_BUILD=20180507							  #
# LICENSE="MIT"										  #
#######################################################

main_menu() {
	local _TITLE="PLAT Functionality Tester - Main Menu"
	local _MESSAGE="Which module would you like to test?"
	local _HEIGHT=
	local _WIDTH=
	local _MENU_HEIGHT=
	local -A _OPTIONS=([A]="All" [T]="Terminal Interaction" [FS]="FileSystem" [DB]="DataBase")
	# fun: dialog_menu TITLE_str MESSAGE_str HEIGHT_int WIDTH_int MENU_HEIGHT_int OPTIONS_ass_array ANSWER_var
	




}
