# Restic Backup

A tiny bash script wrapper around [Restic](https://restic.net/) to backup folders on your machine to an S3 bucket with snapshots

## Highlights

1. Backs up to an S3 bucket
2. Keeps upto N (default: 5) snapshots, deletes older ones
3. Captures logs to a log file in same folder, with logrotate applied
4. Optionally triggers OpsGenie alerts in case of failures
	- Leave OpsGenie key blank to not trigger an alert on failure
5. No root access needed

## Setup

1. Install `logrotate` and `restic` in case they are not already available in your environment:
	```
	sudo apt install logrotate restic
	```
2. Copy over `config.sh.sample` to `config.sh`
3. Configure the variables in `config.sh` as needed
3. Replace `myuser` in `log_rotate.conf` with your user name

> NOTE: Restic backups are encrypted. You'd best not forget the password supplied to it in `config.sh` :)

## Running

1. Run the one time init: `backup.sh init`
2. Now run `backup.sh backup` to create the backup snapshot

## Running in Cron

Run this job on a daily basis at 9pm

```
0 21 * * * cd /home/myuser/backup_script_dir && ./backup.sh backup
```