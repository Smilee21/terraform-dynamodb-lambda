import os
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE']

def lambda_handler(event, context):
    logger.info(f"Event received: {event}")
    
    table = dynamodb.Table(table_name)

    prompt_id = event.get("prompt_id")
    parameters = event.get("parameters", {})

    if not prompt_id:
        logger.error("Missing 'prompt_id' in the event")
        return {
            "statusCode": 400,
            "body": "Missing 'prompt_id' in the event"
        }

    try:
        response = table.get_item(Key={'prompt_id': prompt_id})
        if 'Item' not in response:
            logger.error(f"Prompt with ID {prompt_id} not found")
            return {
                "statusCode": 404,
                "body": f"Prompt with ID {prompt_id} not found"
            }

        prompt_content = response['Item']['content']
        logger.info(f"Prompt found: {prompt_content}")
    except Exception as e:
        logger.error(f"Error retrieving prompt from DynamoDB: {str(e)}")
        return {
            "statusCode": 500,
            "body": "Error retrieving prompt from DynamoDB"
        }

    for key, value in parameters.items():
        placeholder = f"{{{key}}}"
        prompt_content = prompt_content.replace(placeholder, value)

    logger.info(f"Replaced prompt: {prompt_content}")

    return {
        "statusCode": 200,
        "body": f"Prompt with replaced values: {prompt_content}"
    }
