%include common.inc
Name:           erp5-standalone-erp5-3
Summary:        ERP5 standalone - ERP5-3

%description
ERP5 provided with standalone package - ERP5-3.

%install
mkdir -p %{buildroot}/opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/parts
cp -a \
  /opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/parts/[f-pF-P]* \
  %{buildroot}/opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/parts/
%files
%defattr(-,slapsoft,slapsoft)
/opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/