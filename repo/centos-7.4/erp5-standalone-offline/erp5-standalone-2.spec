%include common.inc
Name:           erp5-standalone-erp5-2
Summary:        ERP5 standalone - ERP5-2

%description
ERP5 provided with standalone package - ERP5-2.

%install
mkdir -p %{buildroot}/opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/parts
cp -a \
  /opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/parts/[eE]* \
  %{buildroot}/opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/parts/
%files
%defattr(-,slapsoft,slapsoft)
/opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/