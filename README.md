## Installing Istio on Minikube with Terraform

This guide outlines the steps for installing Istio on Minikube using Terraform.

Prerequisites:

• Minikube installed and running
• Terraform installed
• Helm installed

Instructions:

1. Initialize Terraform:
  * Navigate to your working directory where the Terraform script is located.
  * Run the following command:
        terraform init
        
2. Check Terraform plan:
  * Run the following command to see the plan:
        terraform plan
    

3. Apply the Terraform script:
  * Run the following command to create the resources:
        terraform apply
    

4. Access Httpd application:
  * Once the Terraform script completes, open your web browser and navigate to:
    ```
    http://ingress.istio.local
    ```
  * You should now be able to access the Httpd application running within the Istio service mesh.
