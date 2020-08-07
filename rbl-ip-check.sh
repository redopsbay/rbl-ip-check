#!/bin/bash

function Blacklist_Check() {

  if [ $# -ne 1 ]
  then 
    Error "Please specify a Domain/FQDN or IP as a parameter."
  fi

  FQDN=$(echo $1 | grep -P "(?=^.{5,254}$)(^(?:(?!\d+\.)[a-za-z0-9_\-]{1,63}\.?)+(?:[a-za-z]{2,})$)")

  if [[ $FQDN ]]
  then
    echo "Domain: $1"
    domain_name=$(host $1 | head -n1 | awk '{print $4}')
    Reverse $domain_name "IP not valid or domain cannot not be resolved."

  else
    echo "IP: $1"
    Reverse $1 "IP not valid."
  fi
  Blacklists $1
}

function Reverse() {

  reverse=$(echo $1 |
  sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\4.\3.\2.\1~p")

  if [ "x${reverse}" = "x" ]
  then
    error $2 
    exit 1
  fi
}


function Blacklists() {
  rDNS=$(dig +short -x $1)
  echo $1 name ${rDNS:----}
  for bl in ${blacklister}
  do
      printf $(env tz=utc date "+%m-%d-%y")
      printf "%-50s%-20s" "${reverse}.${bl}. " $1
      listed="$(dig +short -t a ${reverse}.${bl}.)"
      blisterip="$(dig +short -t a ${bl}.)"
      if [[ $listed ]]
      then
        if [[ $listed == *"timed out"* ]]
        then
          echo "[timed out]" | ColorEcho YELLOW 
        else
          echo "[blacklisted] (${blisterip})" | ColorEcho LRED
        fi
      else
          echo "[not listed]" | ColorEcho LBLUE
      fi
  done
}

Error() {
  echo $0 error: $1 >&2
  exit 2
}


ColorEcho(){
  LBLUE='\e[1;94m'
  LRED="\033[1;31m"
  YELLOW="\033[1;33m"
  NORMAL="\033[m"
  color=\$${1:-NORMAL}
  echo -ne "$(eval echo ${color})"
  cat
  echo -ne "${NORMAL}"
}

#### blacklists - grabbed from https://hetrixtools.com/blacklist-check ####
blacklister="
0spam.fusionzero.com
access.redhawk.org
all.s5h.net
all.spamrats.com
aspews.ext.sorbs.net
babl.rbl.webiron.net
backscatter.spameatingmonkey.net
b.barracudacentral.org
bb.barracudacentral.org
black.junkemailfilter.com
bl.blocklist.de
bl.drmx.org
bl.konstant.no
bl.mailspike.net
bl.nosolicitado.org
bl.nszones.com
block.dnsbl.sorbs.net
bl.rbl.scrolloutf1.com
bl.scientificspam.net
bl.score.senderscore.com
bl.spamcop.net
bl.spameatingmonkey.net
bl.suomispam.net
bsb.empty.us
cart00ney.surriel.com
cbl.abuseat.org
cbl.anti-spam.org.cn
cblless.anti-spam.org.cn
cblplus.anti-spam.org.cn
cdl.anti-spam.org.cn
combined.rbl.msrbl.net
db.wpbl.info
dnsbl-1.uceprotect.net
dnsbl-2.uceprotect.net
dnsbl-3.uceprotect.net
dnsbl.cobion.com
dnsbl.dronebl.org
dnsbl.justspam.org
dnsbl.kempt.net
dnsbl.net.ua
dnsbl.rv-soft.info
dnsbl.rymsho.ru
dnsbl.sorbs.net
dnsbl.spfbl.net
dnsbl.tornevall.org
dnsbl.zapbl.net
dnsrbl.org
dnsrbl.swinog.ch
dul.dnsbl.sorbs.net
dyna.spamrats.com
dyn.nszones.com
escalations.dnsbl.sorbs.net
fnrbl.fast.net
hostkarma.junkemailfilter.com
http.dnsbl.sorbs.net
images.rbl.msrbl.net
sip-sip24.invaluement.local
ips.backscatterer.org
ix.dnsbl.manitu.net
l1.bbfh.ext.sorbs.net
l2.bbfh.ext.sorbs.net
l4.bbfh.ext.sorbs.net
list.bbfh.org
mail-abuse.blacklist.jippg.org
misc.dnsbl.sorbs.net
multi.surbl.org
netscan.rbl.blockedservers.com
new.spam.dnsbl.sorbs.net
noptr.spamrats.com
old.spam.dnsbl.sorbs.net
pbl.spamhaus.org
phishing.rbl.msrbl.net
pofon.foobar.hu
problems.dnsbl.sorbs.net
proxies.dnsbl.sorbs.net
psbl.surriel.com
rbl2.triumf.ca
rbl.abuse.ro
rbl.blockedservers.com
rbl.dns-servicios.com
rbl.efnet.org
rbl.efnetrbl.org
rbl.interserver.net
rbl.realtimeblacklist.com
recent.spam.dnsbl.sorbs.net
relays.dnsbl.sorbs.net
rep.mailspike.net
safe.dnsbl.sorbs.net
sbl.spamhaus.org
smtp.dnsbl.sorbs.net
socks.dnsbl.sorbs.net
spam.dnsbl.anonmails.de
spam.dnsbl.sorbs.net
spamlist.or.kr
spam.pedantic.org
spam.rbl.blockedservers.com
spamrbl.imp.ch
spam.rbl.msrbl.net
spamsources.fabel.dk
spam.spamrats.com
srn.surgate.net
stabl.rbl.webiron.net
st.technovision.dk
talosintelligence.com
torexit.dan.me.uk
truncate.gbudb.net
ubl.unsubscore.com
virus.rbl.msrbl.net
web.dnsbl.sorbs.net
web.rbl.msrbl.net
xbl.spamhaus.org
zen.spamhaus.org
z.mailspike.net
zombie.dnsbl.sorbs.net
0spamurl.fusionzero.com
uribl.zeustracker.abuse.ch
uribl.abuse.ro
bsb.empty.us
bsb.spamlookup.net
ex.dnsbl.org
in.dnsbl.org
bl.fmb.la
communicado.fmb.la
nsbl.fmb.la
short.fmb.la
black.junkemailfilter.com
ubl.nszones.com
uribl.pofon.foobar.hu
abuse.rfc-clueless.org
bogusmx.rfc-clueless.org
dsn.rfc-clueless.org
elitist.rfc-clueless.org
fulldom.rfc-clueless.org
postmaster.rfc-clueless.org
whois.rfc-clueless.org
mailsl.dnsbl.rjek.com
urlsl.dnsbl.rjek.com
rhsbl.rymsho.ru
public.sarbl.org
rhsbl.scientificspam.net
nomail.rhsbl.sorbs.net
badconf.rhsbl.sorbs.net
rhsbl.sorbs.net
fresh.spameatingmonkey.net
fresh10.spameatingmonkey.net
fresh15.spameatingmonkey.net
uribl.spameatingmonkey.net
urired.spameatingmonkey.net
dbl.spamhaus.org
dnsbl.spfbl.net
dbl.suomispam.net
multi.surbl.org
dob.sibl.support-intelligence.net
uri.blacklist.woody.ch
rhsbl.zapbl.net
sa.fmb.la
hostkarma.junkemailfilter.com
nobl.junkemailfilter.com
reputation-domain.rbl.scrolloutf1.com
reputation-ns.rbl.scrolloutf1.com
iddb.isipp.com
_vouch.dwl.spamhaus.org
dnswl.spfbl.net
sender.office.com
spamrl.com
"

Blacklist_Check $1
