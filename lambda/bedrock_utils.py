import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_bedrock_client(region="us-west-2"):
    return boto3.client("bedrock-runtime", region_name=region)

MODEL_ID = "anthropic.claude-3-5-sonnet-20240620-v1:0"

def send_to_sonnet(client, prompt, temperature, max_tokens, top_p):
    conversation = [
        {
            "role": "user",
            "content": [{"text": prompt}],
        }
    ]
    try:
        logger.info(f"Sending prompt to Sonnet model: {prompt}")
        response = client.converse(
            modelId=MODEL_ID,
            messages=conversation,
            inferenceConfig={
                "maxTokens": max_tokens,
                "temperature": temperature,
                "topP": top_p,
            },
        )

        model_output = response["output"]["message"]["content"][0]["text"]
        logger.info(f"Model response: {model_output}")
        return model_output

    except Exception as e:
        logger.error(f"Error invoking Sonnet model '{MODEL_ID}': {str(e)}")
        raise

    
    conversation = [
        {
            "role": "user",
            "content": [{"text": prompt}],
        }
    ]
    try:
        logger.info(f"Sending prompt to Sonnet model: {prompt}")
        response = client.converse(
            modelId=MODEL_ID, 
            messages=conversation,
            inferenceConfig={"maxTokens": 512, "temperature": 0.5, "topP": 0.9},
        )

        model_output = response["output"]["message"]["content"][0]["text"]
        logger.info(f"Model response: {model_output}")
        return model_output

    except Exception as e:
        logger.error(f"Error invoking Sonnet model '{MODEL_ID}': {str(e)}")
        raise
