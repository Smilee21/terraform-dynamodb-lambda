import os
import boto3
from utils import process_prompt, get_configuration, get_prompt_from_db
from bedrock_utils import get_bedrock_client, send_to_sonnet
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

    prompt_id = event.get("prompt")
    if not prompt_id:
        return {
            "statusCode": 400,
            "body": "Missing 'prompt' in the event."
        }

    parameters = event.get("parameters", {})
    
    try:
        prompt_content = get_prompt_from_db(table, prompt_id)
        processed_prompt = process_prompt(prompt_content, parameters) 

        client = get_bedrock_client(region="us-east-1")
        response = send_to_sonnet(client, processed_prompt, temperature, max_tokens, top_p)

        return {
            "statusCode": 200,
            "body": response
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Error invoking the model: {str(e)}"
        }
