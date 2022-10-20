# TermiC: Terminal C
Interactive C/C++ shell created with BASH.
## How it Works
All inputs given to TermiC are append to text file in /tmp directory. Then TermiC compiles that file and runs it. It simply takes the last line back if an output detected as all outputs should be seen once. TermiC nearly fully supports C and C++ as it basically use GCC and G++ compilers. All curly braces starts an inline prompt so nested functions, if/else statements, while/for loops, classes etc. can be used efficiently. I don't know if this kind of concept exist but I hope it would be useful.
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
sudo bash -c "echo -e '#\!/bin/bash\n/bin/termic cpp' > /bin/termic++"
sudo chmod +x /bin/termic
sudo chmod +x /bin/termic++
```
To start TermiC:
```bash
termic # For C shell
termic++ # For C++ shell
```
To remove TermiC system wide:
```bash
sudo rm -f /bin/termic
sudo rm -f /bin/termic++
```
