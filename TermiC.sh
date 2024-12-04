#!/bin/bash

# Copyright (C) 2022  Yusuf Kağan Hanoğlu
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

lang="c"
extension="c"
compiler="gcc"
addInclude=""
versiontxt="1.3.0V"
helptxt="TermiC $versiontxt \nLicensed under GPLv3\
    \n--help -h: \t Shows this help menu
    \n--version -v: \t Shows the version number
		\n\nC Mode: \ttermic\
		\nCPP Mode: \ttermic cpp\
    \n\t\ttermic++
		\nCPP 2017 Mode: \ttermic cpp17\
		\nCPP 2020 Mode: \ttermic cpp20\
		\nTCC Mode: \ttermic tcc\
		\n\nCommands:\
    \nhelp: \t\tShows this help menu\nabort: \t\tAborts inline prompt mode which are entered by curly bracket\
		\nshow: \t\tPrints last successfully compiled source file\nshowtmp: \tPrints last compiled source file with deleted edits\
		\nsave: \t\tSaves source file to working directory\nsavebin: \tSaves binary file to working directory\
		\nclear: \t\tDeletes all declared functions, classes etc. and resets shell\
		\nexit: \t\tDeletes created temp files and exits program\
    \n\nAuthors:\nYusuf Kagan Hanoglu\nMax Schillinger"
[[ $1 == "-h" || $1 == "--help" ]] && echo -e $helptxt && exit
[[ $1 == "-v" || $1 == "--version" ]] && echo $versiontxt && exit
[[ $1 == "tcc" ]] && compiler="tcc"
[[ $1 == "cpp" ]] || [[ $0 =~ \+\+ ]] && lang="c++" && compiler="g++ -fpermissive" && extension="cpp" && addInclude="#include <iostream>\nusing namespace std;\n"
[[ $1 == "cpp17" ]] || [[ $0 =~ \+\+ ]] && lang="c++" && compiler="g++ -fpermissive -std=c++17" && extension="cpp" && addInclude="#include <iostream>\nusing namespace std;\n"
[[ $1 == "cpp20" ]] || [[ $0 =~ \+\+ ]] && lang="c++" && compiler="g++ -fpermissive -std=c++2a" && extension="cpp" && addInclude="#include <iostream>\nusing namespace std;\n"
command -v bat > /dev/null 2>&1 && catcmd="bat -p -l $lang" || catcmd=cat
echo TermiC $versiontxt
echo Language: $lang
echo Compiler: $compiler
echo Type \'help\' for additional information
oldPWD=`pwd`
cd /tmp
sourceFile=`mktemp termic-XXXXXXXX.$extension`
[[ -z "$sourceFile" ]] && exit 1
binaryFile=`basename $sourceFile .$extension`
cacheDir="${XDG_CACHE_HOME:-$HOME/.cache}/termic"
[[ -d $cacheDir ]] || mkdir -p "$cacheDir"
historyFile="$cacheDir/${extension}_history"
history -r "$historyFile"
# disable filename completion on tab
bind -r "\C-i" 2> /dev/null
fullPrompt=""
inlineCounter=0
promptPS1=">> "
initSource="#include \"stdio.h\"\n#include \"stdlib.h\"\n${addInclude}int main() {"
echo -e  $initSource > $sourceFile

trap "echo -e '\nKeyboardInterrupt'" SIGINT
while true;do
	[[ $inlineCounter -gt 0 ]] && promptPS1="   " || promptPS1=">> "
	read -rep "$promptPS1"$(yes ... | head -n $inlineCounter | tr -d '\n') prompt || { [[ $inlineCounter -gt 0 ]] || prompt="exit"; }
	[[ $prompt == "" ]] && continue
	history -s "$prompt"
	[[ $prompt == "exit" ]] && break
	[[ $prompt == "clear" ]] && :> $sourceFile && :> $sourceFile.tmp && :> $binaryFile && fullPrompt="" && inlineCounter=0 && echo -e  $initSource > $sourceFile && continue
	[[ $prompt == "abort" ]] && fullPrompt="" && inlineCounter=0 && continue
	[[ $prompt == "show" ]] && $catcmd $sourceFile && continue
	[[ $prompt == "showtmp" ]] && { [[ -f $sourceFile.tmp ]] && $catcmd $sourceFile.tmp || echo "No .tmp file!"; continue; }
	[[ $prompt == "save" ]] && cp $sourceFile $oldPWD && echo "}" >> $oldPWD/$sourceFile && echo "Source file saved to $oldPWD/$sourceFile" && continue
	[[ $prompt == "savebin" ]] && cp $binaryFile $oldPWD && echo "Binary file saved to $oldPWD/$binaryFile" && continue
	[[ $prompt == "help" ]] && echo -e "$helptxt" && continue
	fullPrompt=`echo "$fullPrompt"; echo "$prompt"`
	fullPrompt=`echo "$fullPrompt" | sed '/^[[:blank:]]*$/d'`
	inlineOpen=`echo $fullPrompt | grep -o '{\|#ifdef' | wc -l`
	inlineClose=`echo $fullPrompt | grep -o '}\|#endif' | wc -l`
	inlineCounter=$((inlineOpen-inlineClose))
	if [[ $inlineCounter -le 0 ]];then
		addOutsideMain=false
		addToBeginning=false
		addSemicolon=";"
		# If include statement
		[[ $prompt == "#include "* ]] && addToBeginning=true && addSemicolon=""
		# If definition
		[[ $prompt == "#define "* ]] && addOutsideMain=true && addSemicolon=""
		# If ifdef/elif/else/endif
		[[ $prompt == "#ifdef"* || $prompt == "#elif"* || $prompt == "#else" || $prompt == "#endif" ]] && addToBeginning=true && addSemicolon=""
		# If function declaration
		[[ $fullPrompt =~ ^.?[[:alnum:]\*:]+[[:blank:]]*[[:alnum:]\*:]*[[:blank:]]*[[:alnum:]\*:]*[[:blank:]]*[[:alnum:]:]+\(.*\)[[:blank:]]*.*\{ ]] && addOutsideMain=true && addSemicolon=""
		# If namespace/class/struct declaration
		[[ $fullPrompt =~ ^.?[[:alnum:]\*:]*[[:blank:]]*(namespace|class|struct)[[:blank:]]*[[:alnum:]\*:]*[[:blank:]]*.*\{ ]] && addOutsideMain=true
		# If if/else if/else/switch/while/do while/for/try/catch
		[[ $fullPrompt =~ ^.?[[:blank:]]*(if|else if|else|switch|while|do|for|try|catch).*\{ ]] && addOutsideMain=false && addToBeginning=false && addSemicolon=""
		[[ $fullPrompt == *";" ]] && addSemicolon=""
		if $addToBeginning;then
			echo "$fullPrompt"$addSemicolon > $sourceFile.tmp
			cat $sourceFile >> $sourceFile.tmp
		elif $addOutsideMain;then
			fullPrompt=`printf "%s" "$fullPrompt" | sed -e 's/[&\\]/\\\&/g'`
			fullPrompt=`echo $fullPrompt`
			sed "/^int main() {/i$fullPrompt$addSemicolon" $sourceFile > $sourceFile.tmp
		else
			cp $sourceFile $sourceFile.tmp
			echo "$fullPrompt$addSemicolon" >> $sourceFile.tmp
		fi
		fullPrompt=""
		if $compiler -w -x$lang <(cat $sourceFile.tmp; echo "}") -o $binaryFile
		then
			retval=`./$binaryFile 2>&1`
			[[ $retval == "" ]] && mv $sourceFile.tmp $sourceFile || echo "$retval"
		fi
	fi
done

history -a "$historyFile"
rm $sourceFile* &> /dev/null
rm $binaryFile &> /dev/null
