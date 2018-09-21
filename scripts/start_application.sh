#!/bin/bash

kill $(cat /tmp/process.pid)
[ec2-user@ip-172-31-42-122 tmp]$ cat /var/www/lol/start_application.sh
#!/bin/bash

# go to the jar directory
# JAR_DIRECTORY=/var/www/
# cd $JAR_DIRECTORY

# use java to excute jar file
java -jar /var/www/lol/demo-0.0.1-SNAPSHOT.jar > /tmp/output.log 2>&1 &

echo $! > /tmp/process.pid