
# TechEazy DevOps Assignment (Fully Automated)

One Command: **Run only**

\`\`\`
terraform apply -auto-approve
\`\`\`

and everything will be automated, requiring no manual steps.

---

## What this does:
✅ Creates IAM Roles (read-only, write-only)  
✅ Creates private S3 bucket with 7-day lifecycle policy  
✅ Deploys EC2 with app (Java + Git + your repo)  
✅ Uploads EC2 logs + app logs to S3 on shutdown automatically  
✅ Automatically verifies log upload post-shutdown and stores output in \`verification_log.txt\`  

---

## Prerequisites:
✅ AWS CLI configured  
✅ Terraform installed  
✅ AWS key pair name (for SSH if debugging)  
✅ S3 bucket name provided via \`terraform.tfvars\` or CLI

---

## Customization:
- \`bucket_name\` (required)
- \`instance_type\`, \`ami_id\`, \`shutdown_after_minutes\` can be adjusted in \`terraform.tfvars\`.

---

## Cleanup:
Run:
\`\`\`
terraform destroy -auto-approve
\`\`\`
to remove all resources and avoid AWS charges.

---

## Notes:
✅ No hardcoded AWS secrets in the repo  
✅ Fully automatic: run, wait, and check \`verification_log.txt\` for uploaded logs confirmation

---


