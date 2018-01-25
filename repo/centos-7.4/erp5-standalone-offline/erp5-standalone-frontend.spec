%include common.inc
Name:           erp5-standalone-frontend
Summary:        ERP5 standalone frontend

%description
ERP5 provided with standalone package - frontend.

%install
mkdir -p %{buildroot}/opt/slapgrid
cp -a /opt/slapgrid/57cca7c75d8a9e056dec471068619d3b %{buildroot}/opt/slapgrid
%files
%defattr(-,slapsoft,slapsoft)
/opt/slapgrid/57cca7c75d8a9e056dec471068619d3b