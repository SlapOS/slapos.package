%include common.inc
Name:           erp5-standalone-erp5-2
Summary:        ERP5 standalone - ERP5-2

%description
ERP5 provided with standalone package - ERP5-2.

%install
mkdir -p %{buildroot}/opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/parts
cp -a \
  /opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/parts/[eE]* \
  %{buildroot}/opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/parts/
%files
%defattr(-,slapsoft,slapsoft)
/opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/