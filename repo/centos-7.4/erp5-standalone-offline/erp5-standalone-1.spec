%include common.inc
Name:           erp5-standalone-erp5-1
Summary:        ERP5 standalone - ERP5-1

%description
ERP5 provided with standalone package - ERP5-1.

%install
mkdir -p %{buildroot}/opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/parts
cp -a \
  /opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/.completed \
  /opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/*.cfg \
  /opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/.installed.cfg \
  /opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/.local \
  /opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/bin \
  /opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/eggs \
  /opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/develop-eggs \
  %{buildroot}/opt/slapgrid/bbfe03b53d279b4f595327f751d64e79
cp -a \
  /opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/parts/[a-dA-D]* \
  %{buildroot}/opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/parts/

%files
%defattr(-,slapsoft,slapsoft)
/opt/slapgrid/bbfe03b53d279b4f595327f751d64e79/