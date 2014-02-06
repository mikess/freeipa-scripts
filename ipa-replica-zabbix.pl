#!/usr/bin/env perl
#
# IPA replica monitoring for Zabbix Monitoring
#
# (C) Michal Kulling 02.2014
#
# Example:
# ./ipa-replica-zabbix.pl
# 0
# All is fine (zero), or 1 - run ipa-replica-monitoring.pl script
# for more details
# 

use Net::LDAP;

use strict;
use warnings;

# LDAP connection monitoring
# Settings host, IP, DN and base
my %IPA_MASTER = (
'host' => 'freeipa1.local',
'ip'=> '10.1.10.1', # unused
'dn' => 'dc=company,dc=org',
'base' => 'cn=users,cn=accounts,dc=company,dc=org'
);	

my %IPA_REPLICA = (
'host' => 'freeipa2.local',
'ip'=> '10.1.10.2', # unused
'dn' => 'dc=company,dc=org',
'base' => 'cn=users,cn=accounts,dc=company,dc=org'
);


# LDAP connection to master server
my $M_ldap = Net::LDAP->new($IPA_MASTER{'host'});
my $M_mesg = $M_ldap->bind($IPA_MASTER{'dn'});
$M_mesg = $M_ldap->search(filter=>"(uid=*)", base=>$IPA_MASTER{'base'},
			attrs=> [
				'uid', 			   # uid - login name
				'krbPasswordExpiration',   # when password expire
				'mail',			   # email address
				'nsaccountlock',	   # account locked?
				'displayName'],		   # display name, eg. Name Lastname
			scope=>"one");
my @M_data = $M_mesg->entries;
my $M_count = @M_data;

# LDAP connection to replica server
my $R_ldap = Net::LDAP->new($IPA_REPLICA{'host'});
my $R_mesg = $R_ldap->bind($IPA_REPLICA{'dn'});
$R_mesg = $R_ldap->search(filter=>"(uid=*)", base=>$IPA_REPLICA{'base'},
			attrs=> [
				'uid',                     # uid - login name
				'krbPasswordExpiration',   # when password expire
				'mail',                    # email address
				'nsaccountlock',           # account locked?
				'displayName'],            # display name, eg. Name Lastname
			scope=>"one");
my @R_data = $R_mesg->entries;
my $R_count = @R_data;

######### MAIN BLOCK ##########
if($R_count > $M_count){
	my $c = $R_count - $M_count;
	print "1";
	exit 1;
}elsif($M_count > $R_count){
	my $c = $M_count - $R_count;
	print "1";
	exit 1;
}else{
	print "0";
	exit 0;
}
