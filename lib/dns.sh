####################################################################
# Author: Rodrigo Augosto C.
# date: May 3, 2010
# credits: http://code.google.com/p/pyactiveresource/
####################################################################
set_dns(){

echo "
\"\"\"
Automatically add Google MX records to a domain using Slicehost DNS.

Requires::
    PyActiveResource: http://superjared.com/projects/pyactiveresource/
    
Edit the zone_id below, add your api password and run. To find your zone_id, 
go to the DNS tab of the SliceManager, click the 'edit' next to your 
domain. The URL will have the id::

    https://manage.slicehost.com/zones/<zone_id>/edit
    
\"\"\"

from pyactiveresource.activeresource import ActiveResource
import sys

zone_id = $zone_id
api_password = '$api_password'
google_string = '$google_unique_string'
spf_value = 'v=spf1 a mx include:aspmx.googlemail.com ~all'
ttl_value = '14400'
api_site = 'https://%s@api.slicehost.com/' % api_password

class Zone(ActiveResource):
    _site = api_site
        
class Record(ActiveResource):
    _site = api_site

$dns
    
def main():
    z = Zone.find(zone_id)
    for d in data:
        r = Record({'zone_id': z.id, 'record_type': d[0], 'name': d[1] , 'data': d[2],  'aux': d[3],  'ttl' : ttl_value, 'active' : 'Y'})
        print 'Save record for [',r.save(),'] for:\t',d[1],'\t-\t',d[2]

        
if __name__ == '__main__':
    main()
" > ./set_DNS.py

	####################################################################
	# set new path to install pyactiveresource
	####################################################################
	sed "/^.*package_dir=.*$/ s/src/\$base_path\/resources\/pyactiveresource\/src/" $base_path/resources/pyactiveresource/setup.py  > tmp
	cat tmp > $base_path/resources/pyactiveresource/setup.py
	sudo python $base_path/resources/pyactiveresource/setup.py install
	####################################################################
	# set new path to install pyactiveresource
	####################################################################
	sed "/^.*package_dir=.*$/ s/\$base_path\/resources\/pyactiveresource\/src/src/" $base_path/resources/pyactiveresource/setup.py  > tmp
	cat tmp > $base_path/resources/pyactiveresource/setup.py
	####################################################################
	# Setting DNSs
	####################################################################
	sudo python set_DNS.py
	rm -f set_DNS.py
	echo -e "$cyan=============== DNS & Records setted successfully ===============$endColor"
}
