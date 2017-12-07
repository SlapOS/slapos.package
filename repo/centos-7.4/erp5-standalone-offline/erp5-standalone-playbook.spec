%include common.inc
Name:           erp5-standalone-playbook
Summary:        ERP5 standalone playbook

%description
ERP5 provided with standalone package - playbook.

%install
mkdir -p %{buildroot}/opt/
cp -a /opt/slapos.playbook %{buildroot}/opt/
%files
/opt/slapos.playbook