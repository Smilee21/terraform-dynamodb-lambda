import os
import boto3
from utils import process_prompt, get_configuration
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE']

def lambda_handler(event, context):
    table = dynamodb.Table(table_name)
    config_key = {"pk": "CONFIGURATION", "sk": "BEDROCK_SETTINGS"}
    bedrock_settings = get_configuration(table, config_key)

    if not bedrock_settings:
        return {
            "statusCode": 500,
            "body": "Configuration not found in DynamoDB."
        }

    temperature = bedrock_settings.get("temperature", 0.5)
    max_tokens = bedrock_settings.get("maxTokens", 512)
    top_p = bedrock_settings.get("topP", 0.9)

    prompt = event.get("prompt")
    if not prompt:
        return {
            "statusCode": 400,
            "body": "Missing 'prompt' in the event."
        }

    client = get_bedrock_client(region="us-west-2")
    try:
        response = send_to_sonnet(client, prompt, temperature, max_tokens, top_p)
        return {
            "statusCode": 200,
            "body": response
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Error invoking the model: {str(e)}"
        }
