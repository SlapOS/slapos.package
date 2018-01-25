%include common.inc
Name:           erp5-standalone-erp5-5
Summary:        ERP5 standalone - ERP5-5

%description
ERP5 provided with standalone package - ERP5-5.

%install
mkdir -p %{buildroot}/opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/parts
cp -a \
  /opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/parts/[0-9]* \
  %{buildroot}/opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/parts/
%files
%defattr(-,slapsoft,slapsoft)
/opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/