# TermiC: Terminal C
Interactive C/C++ REPL shell created with BASH.
## How to Use
A simple function in TermiC:
```c
[user@FEDORA ~]$ termic
TermiC 1.3.0V
Language: c
Compiler: gcc
Type 'help' for additional information
>> double divide(double a, double b) {
   ...if(b==0) {
   ......return 0;
   ......}
   ...return a/b;
   ...}
>> printf("Division 25/2 is equal %f", divide(25,2))
Division 25/2 is equal 12.500000
>> 
```
Implementing classes in TermiC++:
```cpp
[user@FEDORA ~]$ termic++
TermiC 1.3.0V
Language: c++
Compiler: g++ -fpermissive
Type 'help' for additional information
>> class Student {
   ...public:
   ...Student(int age) {
   ......this->age = age;
   ......}
   ...int getAge() {
   ......return age;
   ......}
   ...private:
   ...int age;
   ...}
>> Student a(15)
>> cout << "Age of student 'a' " << a.getAge()
Age of student 'a' 15
>> 
```
Using vectors in TermiC++:
```cpp
[user@FEDORA ~]$ termic++
TermiC 1.3.0V
Language: c++
Compiler: g++ -fpermissive
Type 'help' for additional information
>> #include <vector>
>> vector<int> a
>> a.push_back(10)
>> a.push_back(11)
>> a.push_back(12)
>> short counter = 0
>> for(auto v:a) {
   ...cout << ++counter << ". element of a is " << v << endl;
   ...}
1. element of a is 10
2. element of a is 11
3. element of a is 12
>> 
```
Note: _stdio.h, stdlib.h and iostream(in TermiC++)_ are included automatically. Prompt will be inside scope of _int main()_ function but all declared functions/namespaces/classes/structs will be declared before _int main()_ automatically.
## How it Works
All inputs given to TermiC are append to text file in /tmp directory. Then TermiC compiles that file and runs it. It simply takes the last line back if an output detected as all outputs should be seen once. TermiC nearly fully supports C and C++ as it basically use GCC and G++ compilers. All curly braces starts an inline prompt so nested functions, if/else statements, while/for loops, classes etc. can be used efficiently. I don't know if there is such a concept, but I hope it will be useful.
#### Prompt Commands
|Commands|Explanation|
|--------|-----------|
|help|Shows the help menu|
|abort|Aborts inline prompt mode which are entered by curly bracket|
|show|Prints last successfully compiled source file|
|showtmp|Prints last compiled source file with deleted edits|
|save|Saves source file to working directory|
|savebin|Saves binary file to working directory|
|clear|Deletes all declared functions,classes etc. and resets shell|
|exit|Deletes created temp files and exits program|

## How to Install
TermiC uses following packages:
```bash
gcc
g++
```
To install dependencies:
```bash
apt install gcc g++ # Debian based distros
dnf install gcc gcc-c++ # Fedora based distros
```
To run TermiC:
```bash
wget "https://raw.githubusercontent.com/hanoglu/TermiC/main/TermiC.sh"
chmod +x TermiC.sh
bash TermiC.sh
```
To install TermiC system wide:
```bash
wget "https://raw.githubusercontent.com/hanoglu/TermiC/main/TermiC.sh"
sudo cp TermiC.sh /bin/termic
sudo ln -sf /usr/bin/termic /usr/bin/termic++
sudo chmod +x /bin/termic
rm -f TermiC.sh
```
Note: [_DEB_](https://github.com/hanoglu/TermiC/releases/download/V1.2.2/termic-1.2.2.deb) and [_RPM_](https://github.com/hanoglu/TermiC/releases/download/V1.3.0/termic-1.3.0.noarch.rpm) files in [releases](https://github.com/hanoglu/TermiC/releases/tag/V1.3.0) page can be used to install TermiC in Debian/Fedora based systems. Also _COPR repository_ can be used to install TermiC in Fedora based distros.<br><br>
Install with COPR:
```bash
sudo dnf copr enable hanoglu/termic
sudo dnf install termic
```
To start TermiC:
```bash
termic # For C shell
termic++ # For C++ shell
termic tcc # For C shell using the tcc compiler
```
To remove TermiC system wide:
```bash
sudo rm -f /bin/termic
sudo rm -f /bin/termic++
```
