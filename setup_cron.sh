#!/bin/bash
# setup_cron.sh

# This script sets up a cron job for weekly GitHub updates

# Create a cron job that runs every Sunday at 10:00 AM
(crontab -l 2>/dev/null; echo "0 10 * * 0 /home/johnycash/ai-tools/githubupdater/weekly_update.sh") | crontab -

echo "Cron job set up successfully!"
echo "The weekly update script will run every Sunday at 10:00 AM"

# To view your current cron jobs, run: crontab -l
# To remove all cron jobs, run: crontab -r