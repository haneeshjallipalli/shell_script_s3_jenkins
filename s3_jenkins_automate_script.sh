#!/bin/bash

# Define constants
JENKINS_HOME="/var/lib/jenkins"
S3_BUCKET="jenkins-cost-optimization"
DATE=$(date +%Y-%m-%d)

# Check if AWS CLI is installed
if ! command -v aws &>/dev/null; then
    echo "AWS CLI is not installed. Please install it to proceed."
    exit 1
fi

# Iterate through all job directories
for job_dir in "$JENKINS_HOME/jobs/"*/; do
    job_name=$(basename "$job_dir")

    # Iterate through build directories for the job
    for build_dir in "$job_dir/builds/"*/; do
        # Get build number and log file path
        build_number=$(basename "$build_dir")
        log_file="$build_dir/log"

        # Check if log file exists and was created today
        if [ -f "$log_file" ] && [ "$(date -r "$log_file" +%Y-%m-%d)" == "$DATE" ]; then
            # Upload log file to S3 with the build number as the filename
            if aws s3 cp "$log_file" "s3://$S3_BUCKET/$job_name-$build_number.log" --only-show-errors; then
                echo "Uploaded: $job_name/$build_number to s3://$S3_BUCKET/$job_name-$build_number.log"
            else
                echo "Failed to upload: $job_name/$build_number"
            fi
        fi
    done
done
