#### Before starting with the Project, you must create a storage bucket to use GCP Storage Buckets as a backend.

#### Select or create a project
1. In the Google Cloud console, go to the project selector page.
2. Select or create a Google Cloud project.
3. Copy the Project ID and use it in zopsmart-infra terragrunt.hcl as an input variable (eg. project_id = demo-dev-project-12345)


#### Create a Service Account
1. In the Google Cloud console, go to IAM & Admin page
2. Select the root project, which is created in the previous steps
3. Click on Create `Service Account` button

    3.1. Enter a name and description for the Service Account
    
    3.2. Grant the Service Account access to the project, add the following roles
            `Editor`
            `Kubernetes Engine Admin`
            `Project IAM Admin`
            `Role Administrator`
            `Secret Manager Admin`
            `Service Networking Admin`
            `Storage Admin`
            `DNS Administrator`
            `Artifact Registry Administrator`

4. Generate key file:
  
    4.1 Goto Manage Keys

    4.2 Click on `ADD KEY`, select `Create new key`

5. Store the key file in zopsmart-infra/gcp/credentials/**`project-id`**.json

#### Create a Service Account with GCR access in Shared-services Account
1. In the Google Cloud console, go to IAM & Admin page
2. Select the root project, which is created in the previous steps
3. Click on Create `Service Account` button

   3.1. Enter a name and description for the Service Account

   3.2. Grant the Service Account access to the project, add the following roles
         `Storage Object Viewer`

4. Generate key file:

   4.1 Goto Manage Keys

   4.2 Click on `ADD KEY`, select `Create new key`

5. Store the key file in zopsmart-infra/gcp/credentials/gcr-io.json

#### Create Cloud Storage Bucket
1. Enable the Google Cloud Storage API
2. Click on Create bucket. Provide the required details such as name, location, storage class etc.
3. Click create.


#### Store the credentials in the following path of zopsmart-infra repo as below
```
|-- zopsmart-infra
|   |--gcp
|   |   |--credentials
|   |   |   |**`project-id`**.json
|   |   |   |**`shared-service`**.json

```