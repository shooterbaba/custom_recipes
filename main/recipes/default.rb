# This is default setup recipe for java app
include_recipe 'opsworks_java::tomcat_service'
# Install nfs client package for remote directory mount
package 'nfs-common'

# Create the hardcoded path in application for DB
execute 'ls -ld /db-data || mkdir /db-data'

# Mount the NFS directory to this location
execute "mount | grep db-data > /dev/null || mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).#{node[:nfs_endpoint]}:/ /db-data"

template "/var/lib/tomcat7/conf/server.xml" do
  source "server.xml.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, 'service[tomcat]', :immediately
end
