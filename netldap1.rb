require 'net/ldap'

ldap = Net::LDAP.new
ldap.host = "localhost"
ldap.port = 389
ldap.auth "cn=admin,dc=nodomain", "admin"
if ldap.bind == false
    puts "auth failed"
    exit
else
    puts "auth succeeded"
end


filter = Net::LDAP::Filter.eq("cn", "user1")
treebase = "dc=nodomain"

ldap.search(:base => treebase, :filter => filter) do |entry|
    puts "DN: #{entry.dn} is part of the following groups:"
    check = Net::LDAP::Filter.eq("member", entry.dn)
    groups = ldap.search(:base => treebase, :filter => check)
    groups.each do |group|
        puts "#{group.cn}"
    end
end
