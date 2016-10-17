# This is default setup recipe for java app
include_recipe 'opsworks_java::tomcat_service'
# Install nfs client package for remote directory mount
package 'nfs-common'

# Create the hardcoded path in application for DB
execute 'ls -ld /Users/dcameron/persistence || mkdir -p /Users/dcameron/persistence'
execute 'chown tomcat7:tomcat7 /Users/dcameron/persistence'

# Mount the NFS directory to this location
if not node[:nfs_endpoint].nil?
   execute "mount | grep persistence > /dev/null || mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).#{node[:nfs_endpoint]}.efs.#{node[:opsworks][:instance][:region]}.amazonaws.com:/ /Users/dcameron/persistence"
   execute "chown tomcat7:tomcat7 -R /Users/dcameron/persistence"
end

template "/var/lib/tomcat7/conf/server.xml" do
  source "server.xml.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, 'service[tomcat]', :immediately
end
