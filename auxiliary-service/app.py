
from dotenv import load_dotenv
from flask import Flask, jsonify
import boto3
import os
import logging
import botocore

app = Flask(__name__)
logging.basicConfig(level=logging.DEBUG)

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env')) # for local testing

AWS_REGION = os.getenv("AWS_REGION", "eu-west-1")

s3 = boto3.client("s3", region_name=AWS_REGION, aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"), aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"))
ssm = boto3.client("ssm", region_name=AWS_REGION, aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"), aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"))
VERSION = os.getenv("SERVICE_VERSION", "1.0.0")
PARAM_PREFIX = "/kantox-challenge/dev"

@app.route("/s3-buckets")
def list_buckets():
    response = s3.list_buckets()
    buckets = [bucket["Name"] for bucket in response["Buckets"]]
    return jsonify({"buckets": buckets, "version": VERSION})

@app.route("/parameters")
def list_parameters():
    response = ssm.describe_parameters()
    params = [param["Name"] for param in response["Parameters"]]
    return jsonify({"parameters": params, "version": VERSION})

@app.route("/parameter/<name>")
def get_parameter(name):
    try:
        # Prepend prefix
        full_name = f"{PARAM_PREFIX}/{name}"
        logging.debug(f"Input name: {name}, Resolved full_name: {full_name}")
        response = ssm.get_parameter(Name=full_name)
        return jsonify({"value": response["Parameter"]["Value"], "version": VERSION})
    except botocore.exceptions.ClientError as e:
        error_code = e.response.get("Error", {}).get("Code")
        logging.error(f"ClientError - Code: {error_code}, Message: {str(e)}, Full name: {full_name}")
        if error_code == "ParameterNotFound":
            return jsonify({"error": f"Parameter {name} not found"}), 404
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        logging.error(f"Unexpected error for parameter {name}: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8001)