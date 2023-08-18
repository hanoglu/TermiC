Name: termic
Version: 1.3
Release: 1%{?dist}
BuildArch: noarch
Summary: GCC powered interactive C/C++ terminal created with BASH

License: GPLv3
URL: https://github.com/hanoglu/termic
Source0: %{url}/raw/copr/%{name}-%{version}.tar.gz

Requires: bash gcc gcc-c++

%description
TermiC is an interactive C/C++ terminal powered by GCC and written in BASH.
It provides a convenient way to experiment with C/C++ code snippets.

%prep
%autosetup


%install
install -D -m 755 %{name} %{buildroot}/%{_bindir}/%{name}
install -D -m 644 %{name}.1 %{buildroot}/%{_mandir}/man1/%{name}.1

%check

%files
%{_bindir}/%{name}
%{_mandir}/man1/%{name}.1.gz
%license LICENSE.txt
%doc %{name}.1
%changelog
%autochangelog
