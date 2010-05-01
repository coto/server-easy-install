"""
Automatically add Google MX records to a domain using Slicehost DNS.

Requires::
    PyActiveResource: http://superjared.com/projects/pyactiveresource/
    
Edit the zone_id below, add your api password and run. To find your zone_id, 
go to the DNS tab of the SliceManager, click the 'edit' next to your 
domain. The URL will have the id::

    https://manage.slicehost.com/zones/<zone_id>/edit
    
"""

from pyactiveresource.activeresource import ActiveResource
import sys

zone_id = 122655
api_password = '96b2c47d077b0d7da7809c436bf7773861bced0809308cafb70c50f751beac40'
google_unique_string = 'googleffffffff8941e7bb'
spf_value = 'v=spf1 a mx include:aspmx.googlemail.com ~all'
ttl_value = '14400'
api_site = 'https://%s@api.slicehost.com/' % api_password
ipServer='204.232.205.237'

class Zone(ActiveResource):
    _site = api_site
        
class Record(ActiveResource):
    _site = api_site

data = (
	('NS',		'@',					'ns1.slicehost.net.',			0),
	('NS',		'@',					'ns2.slicehost.net.',			0),
	('NS',		'@',					'ns3.slicehost.net.',			0),
	('A',		'protoboard.cl.',		ipServer,						0),
	('A',		'aqua',					ipServer,						0),
	('A',		'mail',					ipServer,						0),
	('A',		'mysql',				ipServer,						0),
	('A',		'svn',					ipServer,						0),
	('A',		'trac',					ipServer,						0),
	('A',		'www',					ipServer,						0),
	('CNAME',	google_unique_string,	'google.com.',					0),
	('CNAME',	'calendar',				'ghs.google.com.',				0),
	('CNAME',	'docs',					'ghs.google.com.',				0),
	('CNAME',	'mail',					'ghs.google.com.',				0),
	('CNAME',	'sites',				'ghs.google.com.',				0),
	('MX',		'protoboard.cl.',		'ASPMX.L.GOOGLE.COM.',			10),
    ('MX',		'protoboard.cl.',		'ALT1.ASPMX.L.GOOGLE.COM.',		20),
    ('MX',		'protoboard.cl.',		'ALT2.ASPMX.L.GOOGLE.COM.',		20),
    ('MX',		'protoboard.cl.',		'ASPMX2.GOOGLEMAIL.COM.',		30),
    ('MX',		'protoboard.cl.',		'ASPMX3.GOOGLEMAIL.COM.',		30),
    ('MX',		'protoboard.cl.',		'ASPMX4.GOOGLEMAIL.COM.',		30),
    ('MX',		'protoboard.cl.',		'ASPMX5.GOOGLEMAIL.COM.',		30),
    ('TXT',		'protoboard.cl.',		spf_value,						0),
#    ('CNAME',	'smtp',					'smtp.googlemail.com.',			0),
#    ('CNAME',	'pop',					'pop.googlemail.com.',			0),
#    ('CNAME',	'imap',					'imap.googlemail.com.',			0),
)
    
    
def main():
    z = Zone.find(zone_id)
    for d in data:
        r = Record({'zone_id': z.id, 'record_type': d[0], 'name': d[1] , 'data': d[2],  'aux': d[3],  'ttl' : ttl_value, 'active' : 'Y'})
        print 'Save record for',r.save()

        
if __name__ == '__main__':
    main()
