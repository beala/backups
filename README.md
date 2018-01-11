# Backups

This repo contains my personal backup script which uses [`duplicity`](http://duplicity.nongnu.org/index.html)
for all the heavy lifting. It supports the following features:

- Full and incremental backups with configurable time periods
- Space efficiency (incremental backups contain deltas from previous backups)
- Encryption
- S3 storage

Simply run the script and it will create either a full or incremental backup depending
on the age of the most recent full backup. After the backup completes, backups older
than a certain age are deleted.

Once set up, using this script is as simple as configuring a cronjob:

``` crontab
# Backup at midnight each day
0 0 * * * /home/alex/bin/backup.sh >/dev/null 2>&1
```

As is, this script is configured for my system so it will not work
out of the box for you, but it can be used as a starting point.
The script is straight forward and well commented.

The default settings:

- One full backup per month
- Daily incremental backups
- The two most recent full backups (along with their increments) are kept
- All remote data is encrypted and signed
- Stored to S3 with [infrequent access](https://aws.amazon.com/s3/storage-classes/) enabled, costing about a cent per gig per month.

# License

Copyright 2018 Alex Beal

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.