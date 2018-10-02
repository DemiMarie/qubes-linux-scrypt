Name:		scrypt
Version:	1.2.1
Release:	1%{?dist}
Summary:	A simple password-based encryption utility

Group:		System Environment/Base
License:	BSD
URL:		https://www.tarsnap.com/scrypt.html
Source0:	https://www.tarsnap.com/scrypt/scrypt-%{version}.tgz
Source1:	https://www.tarsnap.com/scrypt/scrypt-sigs-%{version}.asc

BuildRequires:	gcc
BuildRequires:	openssl-devel
#Requires:	

%description
A simple password-based encryption utility is available as a demonstration of
the scrypt key derivation function. On modern hardware and with default
parameters, the cost of cracking the password on a file encrypted by scrypt enc
is approximately 100 billion times more than the cost of cracking the same
password on a file encrypted by openssl enc; this means that a five-character
password using scrypt is stronger than a ten-character password using openssl. 

%prep
%setup -q

%build
%configure
make %{?_smp_mflags}


%install
%make_install


%files
%doc
/usr/bin/scrypt
/usr/share/man/man1/scrypt.1.gz

%changelog

