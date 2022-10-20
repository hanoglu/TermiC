#!/bin/bash
# Author: Yusuf Kağan Hanoğlu
lang="c"
extension="c"
compiler="gcc"
addInclude=""
[[ $1 == "cpp" ]] && lang="c++" && compiler="g++ -fpermissive" && extension="cpp" && addInclude="#include <iostream>\nusing namespace std;\n"
echo TermiC 1.1V
echo Language: $lang
echo Compiler: $compiler
echo Type \'help\' for additional information
cd /tmp
sourceFile=`mktemp XXXXXXXX.$extension`
binaryFile=`basename $sourceFile .$extension`
fullPrompt=""
inlineCounter=0
promptPS1=">> "
echo -e "#include \"stdio.h\"\n#include \"stdlib.h\"\n${addInclude}int main() {\n" > $sourceFile
while true;do
	[[ $inlineCounter -gt 0 ]] && promptPS1="   " || promptPS1=">> "
	read -ep "$promptPS1"$(echo $(yes ... | head -n $inlineCounter) | sed 's/ //g') prompt
	[[ $prompt == "" ]] && continue
	[[ $prompt == "exit" ]] && break
	[[ $prompt == "help" ]] && echo -e "Designed by Yusuf Kağan Hanoğlu\nLicensed by GPLv3\
		\nC Mode: ./TermiC.sh\
		\nCPP Mode: ./TermiC.sh cpp\
		\n\nCommands:\nhelp: Displays this help page\nexit: Exit program" && continue
	fullPrompt=`echo -e "$fullPrompt\n$prompt"`
	inlineOpen=`echo $fullPrompt | grep -o { | wc -l`
	inlineClose=`echo $fullPrompt | grep -o } | wc -l`  
	inlineCounter=$((inlineOpen-inlineClose))
	if [[ $inlineOpen -gt $inlineClose ]];then
		:	
	else
		addHeader=false
		[[ $prompt == "#include "* ]] && addHeader=true
		if $addHeader;then
			echo "$fullPrompt" > $sourceFile.tmp
			echo "`cat $sourceFile`" >> $sourceFile.tmp
		else
			cp $sourceFile $sourceFile.tmp
			echo "$fullPrompt;" >> $sourceFile.tmp
		fi
		fullPrompt=""
		compiledSuccessfully=false
		$compiler -w -x$lang <(echo "`cat $sourceFile.tmp`}") -o $binaryFile && compiledSuccessfully=true
		
		if $compiledSuccessfully;then
			retval=`./$binaryFile`
			[[ $retval == "" ]] && mv $sourceFile.tmp $sourceFile || echo "$retval"
		fi
	fi
done
rm $sourceFile &> /dev/null
rm $sourceFile.tmp &> /dev/null
rm $binaryFile &> /dev/null
