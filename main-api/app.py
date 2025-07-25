from flask import Flask, jsonify
import requests
import os
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)
AUX_URL = os.getenv("AUXILIARY_SERVICE_URL")
VERSION = os.getenv("SERVICE_VERSION", "1.0.0")

@app.route("/s3-buckets")
def list_buckets():
    resp = requests.get(f"{AUX_URL}/s3-buckets").json()
    return jsonify({"buckets": resp["buckets"], "main_api_version": VERSION, "auxiliary_service_version": resp["auxiliary_service_version"]})

@app.route("/parameters")
def list_parameters():
    resp = requests.get(f"{AUX_URL}/parameters").json()
    return jsonify({"parameters": resp["parameters"], "main_api_version": VERSION, "auxiliary_service_version": resp["auxiliary_service_version"]})

@app.route("/parameter/<name>")
def get_parameter(name):
    resp = requests.get(f"{AUX_URL}/parameter/{name}").json()
    return jsonify({"value": resp["value"], "main_api_version": VERSION, "auxiliary_service_version": resp["auxiliary_service_version"]})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)