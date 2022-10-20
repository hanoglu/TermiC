#!/bin/bash
# Author: Yusuf Kağan Hanoğlu
lang="c"
extension="c"
compiler="gcc"
addInclude=""
[[ $1 == "cpp" ]] && lang="c++" && compiler="g++ -fpermissive" && extension="cpp" && addInclude="#include <iostream>\nusing namespace std;\n"
echo PromtC 1.1V
echo Language: $lang
echo Compiler: $compiler
echo Type \'help\' for additional information
cd /tmp
sourceFile=`mktemp XXXXXXXX.$extension`
binaryFile=`basename $sourceFile .$extension`
fullPromt=""
inlineCounter=0
echo -e "#include \"stdio.h\"\n#include \"stdlib.h\"\n${addInclude}int main() {\n" > $sourceFile
while true;do
	read -ep ">> "$(echo $(yes ... | head -n $inlineCounter) | sed 's/ //g') promt
	[[ $promt == "" ]] && continue
	[[ $promt == "exit" ]] && break
	[[ $promt == "help" ]] && echo -e "Designed by Yusuf Kağan Hanoğlu\nLicensed by BSD\
		\nC Mode: ./PromtC.sh\
		\nCPP Mode: ./PromtC.sh cpp\
		\n\nCommands:\nhelp: Displays this help page\nexit: Exit program" && continue
	fullPromt=`echo -e "$fullPromt\n$promt"`
	inlineOpen=`echo $fullPromt | grep -o { | wc -l`
	inlineClose=`echo $fullPromt | grep -o } | wc -l`  
	inlineCounter=$((inlineOpen-inlineClose))
	if [[ $inlineOpen -gt $inlineClose ]];then
		:	
	else
		addHeader=false
		[[ $promt == "#include "* ]] && addHeader=true
		if $addHeader;then
			echo "$fullPromt" > $sourceFile.tmp
			echo "`cat $sourceFile`" >> $sourceFile.tmp
		else
			cp $sourceFile $sourceFile.tmp
			echo "$fullPromt;" >> $sourceFile.tmp
		fi
		fullPromt=""
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
