%include common.inc
Name:           erp5-standalone
Summary:        ERP5 standalone
Requires:       erp5-standalone-erp5-1 erp5-standalone-erp5-2
Requires:       erp5-standalone-erp5-3 erp5-standalone-erp5-4
Requires:       erp5-standalone-erp5-5
Requires:       erp5-standalone-frontend erp5-standalone-playbook
Requires:       ansible

%description
ERP5 provided with standalone package - metapackage.

%files
%post
echo "# SlapOS ansible offline from erp5-standalone rpm" > /etc/ansible/hosts
echo "[targets]" >> /etc/ansible/hosts
echo "127.0.0.1 ansible_connection=local slapos_ansible_offline=true" >> /etc/ansible/hosts
