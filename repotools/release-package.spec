Name:		%{package_name}
Version:	%{package_version}
Release:	%{release_ver}%{?dist}
Summary:	%{package_name} package

Group:		Applications/System
License:	GPLv3
URL:		http://www.eucalyptus.com

Source0:    %{package_name}.pub
Source1:    %{package_name}.repo
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:  noarch

%description
%{package_name} package


%prep


%build


%install
mkdir -p $RPM_BUILD_ROOT/etc/pki/rpm-gpg
install -pm 644 %{SOURCE0} $RPM_BUILD_ROOT/etc/pki/rpm-gpg/%{package_name}.pub

mkdir -p $RPM_BUILD_ROOT/etc/yum.repos.d
install -pm 644 %{SOURCE1} $RPM_BUILD_ROOT/etc/yum.repos.d/%{package_name}.repo


%files
/etc/pki/rpm-gpg/%{package_name}.pub
/etc/yum.repos.d/%{package_name}.repo

%changelog
* Wed Oct 17 2012 Eucalyptus Release Engineering <support@eucalyptus.com>
- Release package build

