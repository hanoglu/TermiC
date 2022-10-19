#!/bin/bash
# Author: Yusuf Kağan Hanoğlu
lang="c"
extension="c"
compiler="gcc"
addInclude=""
[[ $1 == "cpp" ]] && lang="c++" && compiler="g++" && extension="cpp" && addInclude="#include <iostream>\nusing namespace std;\n"
echo PromtC 1.1V
echo Language: $lang
echo Compiler: $compiler
echo Type \'help\' for additional information
cd /tmp
sourceFile=`mktemp XXXXXXXX.$extension`
binaryFile=`basename $sourceFile .$extension`
echo -e "#include \"stdio.h\"\n#include \"stdlib.h\"\n${addInclude}int main() {\n" > $sourceFile
while true;do
	read -ep ">> " promt
	[[ $promt == "" ]] && continue
	[[ $promt == "exit" ]] && break
	[[ $promt == "help" ]] && echo -e "Designed by Yusuf Kağan Hanoğlu\nLicensed by BSD\
		\nC Mode: ./PromtC.sh\
		\nCPP Mode: ./PromtC.sh cpp\
		\n\nCommands:\nhelp: Displays this help page\nexit: Exit program" && continue
	addHeader=false
	[[ $promt == "#include "* ]] && addHeader=true
	if $addHeader;then
		echo "$promt" > $sourceFile.tmp
		echo "`cat $sourceFile`" >> $sourceFile.tmp
	else
		cp $sourceFile $sourceFile.tmp
		echo "$promt;" >> $sourceFile.tmp
	fi
	compiledSuccessfully=false
	$compiler -w -x$lang <(echo "`cat $sourceFile.tmp`}") -o $binaryFile && compiledSuccessfully=true	

	if $compiledSuccessfully;then
		retval=`./$binaryFile`
		[[ $retval == "" ]] && mv $sourceFile.tmp $sourceFile || echo "$retval"
	fi
done
rm $sourceFile &> /dev/null
rm $sourceFile.tmp &> /dev/null
rm $binaryFile &> /dev/null
