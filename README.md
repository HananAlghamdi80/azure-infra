
## Screenshot of the Application
![E-commerce App](https://raw.githubusercontent.com/HananAlghamdi80/azure-infra/main/Screenshot%202025-09-27%20160754.png)




# Azure Infrastructure Project
This repository contains Terraform code for deploying a 3-Tier Application on Microsoft Azure.  

## Files Included
- main.tf: Resource group and base setup  
- network.tf: Virtual network and subnets  
- sql.tf: Azure SQL Database with private endpoint  
- appgw.tf: Application Gateway with WAF  
- appservice.tf: Web Apps for frontend and backend  
- variables.tf: Input variables  
- outputs.tf: Deployment outputs  
- .gitignore: Ignore state, plan, and sensitive files  

## How to Run
1. Install Terraform  
2. Run the following commands:

terraform init
terraform plan
terraform apply
