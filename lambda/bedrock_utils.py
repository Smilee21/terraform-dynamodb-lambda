import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_bedrock_client(region="us-east-1"):
    return boto3.client("bedrock-runtime", region_name=region)

MODEL_ID = "anthropic.claude-3-5-sonnet-20240620-v1:0"

def send_to_sonnet(client, prompt, temperature, max_tokens, top_p):
    conversation = [
        {
            "role": "user",
            "content": [{"text": prompt}],
        }
    ]
    
    inference_config = {
        "maxTokens": int(max_tokens),
        "temperature": float(temperature),
        "topP": float(top_p),
    }

    try:
        response = client.converse(
            modelId=MODEL_ID,
            messages=conversation,
            inferenceConfig=inference_config,
        )

        model_output = response["output"]["message"]["content"][0]["text"]
        logger.info(f"Model response: {model_output}")
        return model_output

    except Exception as e:
        logger.error(f"Error invoking Sonnet model '{MODEL_ID}': {str(e)}")
        raise
