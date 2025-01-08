# shell_script_s3_jenkins
automate the process of uploading jenkins logs to s3 bucket for cost optimization

## Shell  Script Explanation:
Let's break down these commands and syntaxes in detail:

---

### **1. `if ! command -v aws &>/dev/null;`**
#### Explanation:
- **`command -v aws`:**  
  - Checks if the `aws` command (AWS CLI) is available in the system's `PATH`.
  - If the command exists, it returns the path to the executable. If it doesn't exist, it returns nothing (non-zero exit status).

- **`!`:**  
  - Negates the result of the command. If `command -v aws` fails (indicating the command doesn't exist), the `!` makes the condition true.

- **`&>/dev/null`:**  
  - Redirects **both stdout and stderr** to `/dev/null`, effectively silencing any output from the command.

- **`if`:**  
  - The `if` statement checks the condition (whether `! command -v aws` is true).

#### Purpose:
This ensures the script can detect if the `aws` command is missing and exits with an error message.

---

### **2. `DATE=$(date +%Y-%m-%d)`**
#### Explanation:
- **`DATE=`:**  
  - Assigns the result of the command to the variable `DATE`.

- **`$(...)`:**  
  - Command substitution: Executes the command inside the parentheses and returns its output. This replaces older backtick syntax (`` `command` ``).

- **`date +%Y-%m-%d`:**  
  - The `date` command prints the current date.
  - The `+%Y-%m-%d` specifies the format:
    - `%Y`: Year (4 digits, e.g., 2025)
    - `%m`: Month (2 digits, e.g., 01 for January)
    - `%d`: Day (2 digits)

#### Purpose:
Stores today's date in the format `YYYY-MM-DD` in the `DATE` variable for comparison later.

---

### **3. `job_name=$(basename "$job_dir")`**
#### Explanation:
- **`job_name=`:**  
  - Assigns the result of the command to the variable `job_name`.

- **`basename "$job_dir"`:**  
  - Extracts the last part of a file or directory path.
  - For example, if `job_dir="/var/lib/jenkins/jobs/sample-job/"`, `basename` returns `sample-job`.

#### Purpose:
Extracts the name of the Jenkins job from its directory path for use in S3 file naming.

---

### **4. `if [ -f "$log_file" ] && [ "$(date -r "$log_file" +%Y-%m-%d)" == "$DATE" ]`**
#### Explanation:
- **`if`:**  
  - Begins a conditional statement.

- **`[ -f "$log_file" ]`:**  
  - Checks if the file at `$log_file` exists and is a regular file (not a directory or special file).

- **`&&`:**  
  - Logical AND: Combines two conditions. Both must be true for the entire statement to evaluate as true.

- **`date -r "$log_file" +%Y-%m-%d`:**  
  - `-r "$log_file"` gets the last modification date of the file.
  - `+%Y-%m-%d` formats the date (like in the `DATE` variable).

- **`$(...)`:**  
  - Command substitution: Executes `date -r` and returns its output.

- **`== "$DATE"`:**  
  - Compares the formatted modification date of the log file to today's date.

#### Purpose:
Checks whether the log file exists **and** was last modified today.

---

### **5. `if aws s3 cp "$log_file" "s3://$S3_BUCKET/$job_name-$build_number.log" --only-show-errors;`**
#### Explanation:
- **`aws s3 cp`:**  
  - AWS CLI command to copy a file to/from an S3 bucket.
  - Syntax: `aws s3 cp <source> <destination>`.

- **`"$log_file"`:**  
  - Path to the local log file being uploaded.

- **`"s3://$S3_BUCKET/$job_name-$build_number.log"`:**  
  - Destination path in the S3 bucket. The `$S3_BUCKET`, `$job_name`, and `$build_number` variables create a unique name for each file in the bucket.

- **`--only-show-errors`:**  
  - Suppresses regular output (e.g., progress updates), showing only error messages if something goes wrong.

- **`if`:**  
  - Executes the `aws s3 cp` command and checks its exit status:
    - **0:** Success (upload completed).
    - **Non-zero:** Failure (upload failed).

#### Purpose:
Uploads the log file to the specified S3 bucket and checks if the upload succeeds or fails.

---

### **Recap of New Concepts**
- **`command -v`:** Checks for the presence of a command.
- **`&>/dev/null`:** Silences both stdout and stderr.
- **`$(...)`:** Executes a command and uses its output.
- **`date -r`:** Fetches a file's last modification date.
- **`aws s3 cp`:** Copies files between the local system and S3.

These concepts are common in Bash scripting for automating system-level tasks.
