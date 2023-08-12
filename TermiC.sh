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
[[ $1 == "tcc" ]] && compiler="tcc"
[[ $1 == "cpp" ]] || [[ $0 =~ \+\+ ]] && lang="c++" && compiler="g++ -fpermissive" && extension="cpp" && addInclude="#include <iostream>\nusing namespace std;\n"
echo TermiC 1.2.2V
echo Language: $lang
echo Compiler: $compiler
echo Type \'help\' for additional information
oldPWD=`pwd`
cd /tmp
sourceFile=`mktemp termic-XXXXXXXX.$extension`
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
	prompt=$(read -rep "$promptPS1"$(echo $(yes ... | head -n $inlineCounter) | sed 's/ //g') prompt || { [[ $inlineCounter -gt 0 ]] || prompt="exit"; } ; echo $prompt)
	[[ $prompt == "" ]] && continue
	history -s "$prompt"
	[[ $prompt == "exit" ]] && break
	[[ $prompt == "clear" ]] && :> $sourceFile && :> $sourceFile.tmp && :> $binaryFile && fullPrompt="" && inlineCounter=0 && echo -e  $initSource > $sourceFile && continue
	[[ $prompt == "abort" ]] && fullPrompt="" && inlineCounter=0 && continue
	[[ $prompt == "show" ]] && cat $sourceFile && continue
	[[ $prompt == "showtmp" ]] && cat $sourceFile.tmp && continue
	[[ $prompt == "save" ]] && cp $sourceFile $oldPWD && echo "}" >> $oldPWD/$sourceFile && echo "Source file saved to $oldPWD/$sourceFile" && continue
	[[ $prompt == "savebin" ]] && cp $binaryFile $oldPWD && echo "Binary file saved to $oldPWD/$binaryFile" && continue
	[[ $prompt == "help" ]] && echo -e "Designed by Yusuf Kağan Hanoğlu\nLicensed by GPLv3\
		\nC Mode: ./TermiC.sh\
		\nCPP Mode: ./TermiC.sh cpp\
		\n\nCommands:\nhelp: Shows this help menu\nabort: Aborts inline prompt mode which are entered by curly bracket\
		\nshow: Prints last successfully compiled source file\nshowtmp: Prints last compiled source file with deleted edits\
		\nsave: Saves source file to working directory\nsavebin: Saves binary file to working directory\
		\nclear: Deletes all declared functions, classes etc. and resets shell\
		\nexit: Deletes created temp files and exits program" && continue
	fullPrompt=`echo "$fullPrompt"; echo "$prompt"`
	fullPrompt=`echo $fullPrompt | sed '/^[[:blank:]]*$/d'`
	inlineOpen=`echo $fullPrompt | grep -o { | wc -l`
	inlineClose=`echo $fullPrompt | grep -o } | wc -l`
	inlineCounter=$((inlineOpen-inlineClose))
	if [[ $inlineOpen -gt $inlineClose ]];then
		:
	else
		addOutsideMain=false
		addToBeginning=false
		addSemicolon=";"
		# If include statement
		[[ $prompt == "#include "* ]] && addToBeginning=true && addSemicolon=""
		# If definition
		[[ $prompt == "#define "* ]] && addOutsideMain=true && addSemicolon=""
		# If function declaration
		[[ $fullPrompt =~ ^.?[[:alnum:]\*:]+[[:blank:]]*[[:alnum:]\*:]*[[:blank:]]*[[:alnum:]\*:]*[[:blank:]]*[[:alnum:]:]+\(.*\)[[:blank:]]*.*\{ ]] && addOutsideMain=true && addSemicolon=""
		# If namespace/class/struct declaration
		[[ $fullPrompt =~ ^.?[[:alnum:]\*:]*[[:blank:]]*(namespace|class|struct)[[:blank:]]*[[:alnum:]\*:]*[[:blank:]]*.*\{ ]] && addOutsideMain=true
		# If if/else if/else/switch/while/do while/for/try/catch
		[[ $fullPrompt =~ ^.?[[:blank:]]*(if|else if|else|switch|while|do|for|try|catch).*\{ ]] && addOutsideMain=false && addToBeginning=false && addSemicolon=""
		if $addToBeginning;then
			echo "$fullPrompt"$addSemicolon > $sourceFile.tmp
			echo "`cat $sourceFile`" >> $sourceFile.tmp
		elif $addOutsideMain;then
			fullPrompt=`printf "%s" "$fullPrompt" | sed -e 's/[&\\]/\\\&/g'`
			sed "/^int main() {/i$fullPrompt$addSemicolon" $sourceFile > $sourceFile.tmp
		else
			cp $sourceFile $sourceFile.tmp
			echo "$fullPrompt$addSemicolon" >> $sourceFile.tmp
		fi
		fullPrompt=""
		compiledSuccessfully=false
		$compiler -w -x$lang <(echo "`cat $sourceFile.tmp`}") -o $binaryFile && compiledSuccessfully=true

		if $compiledSuccessfully;then
			retval=`./$binaryFile 2>&1`
			[[ $retval == "" ]] && mv $sourceFile.tmp $sourceFile || echo "$retval"
		fi
	fi
done

history -a "$historyFile"
rm $sourceFile* &> /dev/null
rm $binaryFile &> /dev/null
