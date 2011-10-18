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

#Add a user and later delete him
new_userdn = "cn=phpcreator,ou=users,dc=nodomain"
attr = {
    :cn => 'phpcreator',
    :objectclass => ['inetorgperson'],
    :sn => 'Lerdorf',
    :givenName => 'Rasmus'
}
ldap.add(:dn => new_userdn, :attributes => attr)

rubyists_dn = 'cn=rubyists,ou=groups,dc=nodomain'
groups_base = 'ou=groups,dc=nodomain'

ldap.add_attribute rubyists_dn, :member, new_userdn

rubyists = ldap.search :base => groups_base, :filter => '(cn=rubyists)', 
        :return_result => true

puts "Members of the group:"
rubyists[0].member.each do |member|
    puts "member dn: #{member}"
end

puts "Something is wrong here."

ldap.delete :dn => new_userdn

rubyists = ldap.search :base => groups_base, :filter => '(cn=rubyists)', :return_result => true 
members = rubyists[0].member
if members.include?(new_userdn)
   members.delete new_userdn
   ldap.replace_attribute rubyists_dn, :member, members
end

puts "There fixed that"
puts "Here's the membership now"

ldap.search :base => groups_base, :filter=> '(cn=rubyists)' do |rubyists|
    puts "#{rubyists.member}"
end
