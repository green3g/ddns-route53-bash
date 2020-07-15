# DDNS for Route53

Automatically update AWS route 53 records with current IP address

## Requirements:

 - AWS CLI
 - `jq`: `apt install jq`


Usage:

```
git clone https://github.com/roemhildtg/ddns-route53-bash.git
cd ddns-route53-bash
cp .env.sample .env
# update the .env file with your parameters
chmod +x update-ddns.bash
./update-ddns.bash domain.com. sub.domain.com. sub2.domain.com. ...
```

