%include common.inc
Name:           erp5-standalone-erp5-1
Summary:        ERP5 standalone - ERP5-1

%description
ERP5 provided with standalone package - ERP5-1.

%install
mkdir -p %{buildroot}/opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/parts
cp -a \
  /opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/.completed \
  /opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/*.cfg \
  /opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/.installed.cfg \
  /opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/.local \
  /opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/bin \
  /opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/eggs \
  /opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/develop-eggs \
  %{buildroot}/opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f
cp -a \
  /opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/parts/[a-dA-D]* \
  %{buildroot}/opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/parts/

%files
%defattr(-,slapsoft,slapsoft)
/opt/slapgrid/6a3090a7784f6d884fc47994c066fc4f/