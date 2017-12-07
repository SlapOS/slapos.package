%include common.inc
Name:           erp5-standalone-frontend
Summary:        ERP5 standalone frontend

%description
ERP5 provided with standalone package - frontend.

%install
mkdir -p %{buildroot}/opt/slapgrid
cp -a /opt/slapgrid/b6fd6dcb9e71fdfbeafa00397fd803a5 %{buildroot}/opt/slapgrid
%files
%defattr(-,slapsoft,slapsoft)
/opt/slapgrid/b6fd6dcb9e71fdfbeafa00397fd803a5