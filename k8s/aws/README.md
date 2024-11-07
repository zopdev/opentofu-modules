### Create a IAM user account 
1. SignIn to the AWS Management Console using your AWS account credentials.
2. Search `IAM` in the AWS Management Console.
3. In the IAM console, click on `Users` in the left-hand navigation pane.
4. Click on the `Add user` button to start creating a new IAM user.
5. Enter a name for the user in the `User name` field. This should be a unique name that identifies the user.
6. Under the `Select AWS access type` section, choose whether you want to give the user programmatic access, AWS Management Console access, or both. Select the appropriate options based on your requirements.

   - If you select `Programmatic access` the user will be able to interact with AWS using the AWS CLI or SDKs.
   - If you select `AWS Management Console access` the user will be able to sign in to the AWS Management Console using a password.

7. Then click on the `Create user` button to create the IAM user.

#### If you selected Programmatic access

1. Click on the checkbox next to `Create access key` and then click on the `Next` button.
2. On the next page, review the permissions for the user. By default, the user won't have any permissions. You can attach existing policies to the user or create custom policies to grant specific permissions.

   - To attach existing policies, select the checkbox next to the desired policies.
   - To create a custom policy, click on the `Create policy` button and follow the instructions to define the policy.

3. Once you have selected the desired permissions, click on the `Next` button.
4. Review the user's details and configuration on the next page.
5. Click on the `Create user` button to create the IAM user.
6. On the final page, you will see the user's access key ID and secret access key.