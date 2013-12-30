# Fast and Easy Web Server Installation
 
- Author: Coto Augosto C.
- Twitter: [@coto]
- URL: [beecoss.com]
- Created: Mar 16th, 2010
- Last Updated: Dec 29th, 2013

## Description
Install easily a secure web server on linux. You can choose what you want to install between a lot of packages.

**Fast and Easy Web Server Installation** is a Bash Script project that help you to install and configure a Cross-Linux server with insteresting packages and funtionalities, like Wordpress, MySQL, TRAC, and many more.

### List of packages availables to install and configure:

 * TRAC
 * SVN
 * Iptables (Most secure)
 * SSH (Change port by default and securitize)
 * Apache
 * Django (Web Framework of awesome Python)
 * MySQL
 * Cron Backup of databases, websites, etc
 * Mail Server
 * Virtualhost

### Tested
**Fast and Easy Web Server Installation** was tested on next Linux Operating System
 
 * CentOS
 * Red Hat Enterprise Linux 
 * Ubuntu 12.04.3 x64
 * It is not tested but should work in Mandrake, Debian, Fedora

## Installation

 1. Download the project and extract the project

 ```sh
 curl -LOk https://github.com/coto/server-easy-install/archive/0.3.tar.gz
 tar -xvf 0.3.tar.gz
 ```

 1. Create a config file and run the Bash

 ```
 cd server-easy-install-0.3/
 cp config.sample config
 bash install.sh
 ```

## Licensed under the GPL
http://www.gnu.org/licenses/gpl.html

[@coto]:http://twitter.com/coto
[beecoss.com]:http://www.beecoss.com
 	
