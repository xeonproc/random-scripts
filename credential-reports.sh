#!/bin/bash
export FORCE_NO_ALIAS=true assume root

#GLCP accounts
echo -e "\e[31mGenerating IAM Credential Report for GLCP Accounts.\e[0m"
assume GLC2GLCP_Bridge_Dev --exec 'aws iam generate-credential-report'
assume GLCP_Organizations_Development --exec 'aws iam generate-credential-report'
assume GLCP_Organizations_Integration --exec 'aws iam generate-credential-report'
assume GLCP_Organizations_Production --exec 'aws iam generate-credential-report'
assume GLCP_Service_Identities_Development --exec 'aws iam generate-credential-report'
assume GLCP_Service_Identities_Integration --exec 'aws iam generate-credential-report'
assume GLCP_Service_Identities_Production --exec 'aws iam generate-credential-report'
assume Pioneer_Integration --exec 'aws iam generate-credential-report'
assume Pioneer_Production --exec 'aws iam generate-credential-report'
assume Unified_API_Development --exec 'aws iam generate-credential-report'
assume Unified_API_Integration --exec 'aws iam generate-credential-report'
assume Unified_API_Production --exec 'aws iam generate-credential-report'

#VAS accounts
echo -e "\e[31m Generating IAM Credential Report for VAS Accounts.\e0m"
assume VAS_Marketplace_Dev --exec 'aws iam generate-credential-report'
assume GL_VAS_Intg --exec 'aws iam generate-credential-report'
assume GL_VAS_Prod --exec 'aws iam generate-credential-report'


#Core Services accounts
echo -e "\e[31m Generating IAM Credential Report for Core Services Accounts.\e[0m"
assume GitHub_HPE_ISE_Artifacts --exec 'aws iam generate-credential-report'
assume Redstone_Centralized_IAM_Mgmt --exec 'aws iam generate-credential-report'
assume Redstone_Merlin_Dev --exec 'aws iam generate-credential-report'
assume Redstone_Merlin_Prod --exec 'aws iam generate-credential-report'
assume Redstone_Runtime_Development_Resources --exec 'aws iam generate-credential-report'
assume Redstone_Runtime_Integration_Resources --exec 'aws iam generate-credential-report'
assume Redstone_Runtime_Production_Resources --exec 'aws iam generate-credential-report'

#HPE Core Org Accts
echo -e "\e[31m Generating IAM Credential Report for Core Services Accounts.\e[0m"
assume Redstone_Shared_Services --exec 'aws iam generate-credential-report'
assume Redstone_SecOps --exec 'aws iam generate-credential-report'

#HPE Data Services
echo -e "\e[31m Generating IAM Credential Report for Core Services Accounts.\e0m"
assume Cloud_Backup_Recovery_dev --exec 'aws iam generate-credential-report'
