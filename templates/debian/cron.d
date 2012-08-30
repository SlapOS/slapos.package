SHELL=/bin/sh
PATH=/usr/bin:/usr/sbin:/sbin:/bin
MAILTO=root

*/5 * * * * root /opt/slapos/bin/slapgrid-sr --verbose --logfile=/opt/slapos/slapgrid-sr.log --pidfile=/opt/slapos/slapgrid-sr.pid /etc/opt/slapos/slapos.cfg >> /opt/slapos/slapgrid-sr.log 2>&1
*/5 * * * * root /opt/slapos/bin/slapgrid-cp --verbose --logfile=/opt/slapos/slapgrid-cp.log --pidfile=/opt/slapos/slapgrid-cp.pid /etc/opt/slapos/slapos.cfg >> /opt/slapos/slapgrid-cp.log 2>&1
0 0 * * * root /opt/slapos/bin/slapgrid-ur --verbose --logfile=/opt/slapos/slapgrid-ur.log --pidfile=/opt/slapos/slapgrid-ur.pid /etc/opt/slapos/slapos.cfg >> /opt/slapos/slapgrid-ur.log 2>&1
0 0 * * * root /opt/slapos/bin/slapformat --verbose --log_file=/opt/slapos/slapformat.log -c /etc/opt/slapos/slapos.cfg >> /opt/slapos/slapformat.log 2>&1

