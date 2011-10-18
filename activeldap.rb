require 'active_ldap'
ActiveLdap::Base.setup_connection :host => 'localhost', :base => 'dc=nodomain',
    :bind_dn => 'cn=admin,dc=nodomain', :password => 'admin'


class Group < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'cn',
               :prefix => 'ou=groups', :classes => ['top', 'groupOfNames'],
               :scope => :one
    has_many :members,
        :class_name => "User",
        :wrap => "member"
end

class User < ActiveLdap::Base
    ldap_mapping :dn_attribute => 'cn', :prefix => 'ou=users', :classes => ['top', 'inetorgperson']
    belongs_to :groups, :class_name => 'Group',  :foreign_key=> "dn", :primary_key => 'member'
end

user1 = User.find 'user1'
puts "Found: #{user1.cn} #{user1.sn}"
user1.groups.all.each {|group| puts "   Group: #{group.cn}"}

puts "\n\n"
rubyists = Group.find 'rubyists'
puts "Found Group: #{rubyists.dn}"
rubyists.members.each do|member|
    puts "    Member: #{member.cn} #{member.sn}"
end
