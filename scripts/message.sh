ACCOUNT_SID=ACa5059b3da77d073a9f246983406950a5
AUTH_TOKEN=fff9e58dad569c91a9632cfbc837c09b


FROM_PHONE="+1 270 626 3015"
TO_PHONE="+91 7358451514"


MESSAGE=$1

curl -X POST https://api.twilio.com/2010-04-01/Accounts/$ACCOUNT_SID/Messages.json \
    -u "$ACCOUNT_SID:$AUTH_TOKEN" \
    --data-urlencode "From=$FROM_PHONE" \
    --data-urlencode "To=$TO_PHONE" \
    --data-urlencode "Body=$MESSAGE"


# ACCOUNT_SID=AC6411ef9e05d49a528c8aec3300097c09
# AUTH_TOKEN=7f8f7a74eaa6150f6003b187f9a823f0


# FROM_PHONE="+1 270 813 0217"
# TO_PHONE="+91 9422321048"


 MESSAGE=$1

# curl -X POST https://api.twilio.com/2010-04-01/Accounts/$ACCOUNT_SID/Messages.json \
#     -u "$ACCOUNT_SID:$AUTH_TOKEN" \
#     --data-urlencode "From=$FROM_PHONE" \
#     --data-urlencode "To=$TO_PHONE" \
#     --data-urlencode "Body=$MESSAGE"


# echo $MESSAGE | sudo ssmtp ayushitrivedi310@gmail.com



#!/bin/bash

# # function to send email
# send_email() {
#   # configure ssmtp
#   echo "To: $1" > /tmp/email.txt
#   echo "From: $2" >> /tmp/email.txt
#   echo "Subject: $3" >> /tmp/email.txt
#   echo "" >> /tmp/email.txt
#   echo "$4" >> /tmp/email.txt
#   # send email using ssmtp
#   /usr/sbin/ssmtp -t < /tmp/email.txt
# }

# # get email address from command line argument
# to_email=$1

# # set email parameters
# from_email="noreply@example.com"
# subject="Zomato ETL Job Failed"
# content=$(cat $2)

# # send email
# send_email "$to_email" "$from_email" "$subject" "$content"

#  echo -e "Subject: MODULE1\n\nFAILED" | ssmtp idmakash2002@gmail.com

