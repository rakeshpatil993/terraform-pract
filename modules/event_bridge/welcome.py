import json
import boto3
def lambda_handler(event, context):
   notification = "Here is the SNS notification for Lambda function."
   client = boto3.client('events')
   response = client.publish (
      TargetArn = "arn:aws:sns:ap-southeast-1:613679500838:my-security-sns",
      Message = json.dumps({'default': notification}),
      MessageStructure = 'json'
   )

   return {
      'statusCode': 200,
      'body': json.dumps(response)
   }

  )