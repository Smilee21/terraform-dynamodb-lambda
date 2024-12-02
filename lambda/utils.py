import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def process_prompt(prompt, parameters):
    for key, value in parameters.items():
        placeholder = f"{{{key}}}"
        prompt = prompt.replace(placeholder, value)
    return prompt


def get_configuration(table, key):
    try:
        response = table.get_item(Key=key)
        if "Item" in response:
            logger.info(f"Configuration fetched: {response['Item']}")
            return response["Item"]
        else:
            logger.error(f"Configuration with key {key} not found.")
            return None
    except Exception as e:
        logger.error(f"Error fetching configuration: {str(e)}")
        raise

def get_prompt_from_db(table, prompt_id):
    response = table.get_item(
        Key={'pk': prompt_id, 'sk': 'METADATA'}
    )

    logger.info(f"Response from DynamoDB for prompt: {response}")
    if 'Item' in response:
        return response['Item']['content']  
    else:
        raise Exception(f"Prompt {prompt_id} not found in DB")
