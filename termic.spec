Name:           termic
Version:        0.0.1
Release:        1%{?dist}
Summary:     GCC powered interactive C/C++ terminal created with BASH
BuildArch:     noarch

License:      GPLv3
URL:            https://github.com/hanoglu/TermiC
# Sources can be obtained by
# git clone https://github.com/hanoglu/TermiC
# cd TermiC
# tito build --tgz
Source0:     %{name}-%{version}.tar.gz

Requires:       bash, gcc, gcc-c++

%description
GCC powered interactive C/C++ terminal created with BASH

%install
echo "DENEME:  $PWD"
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_bindir}
cp %{name} $RPM_BUILD_ROOT/%{_bindir}
ln -s %{name} $RPM_BUILD_ROOT/%{_bindir}/%{name}++
chmod +x $RPM_BUILD_ROOT/%{_bindir}/%{name}
chmod +x $RPM_BUILD_ROOT/%{_bindir}/%{name}++

%clean
rm -rf $RPM_BUILD_ROOT

%files
%{_bindir}/%{name}
%{_bindir}/%{name}++

%changelog
* Sat Nov 05 2022 Yusuf Kağan Hanoğlu <hanoglu@yahoo.com> 0.0.1-1
- new package built with tito

* Sat Nov 05 2022 Unknown name 1.0.0-1
- new package built with tito

* Sun Oct 30 2022 Yusuf Kağan Hanoğlu <yusuf@hanoglu.net>
-Improvements:
-Functions, classes, namespaces, structs etc. now can be declared
-New prompt commands implemented
-Various bug fixes
