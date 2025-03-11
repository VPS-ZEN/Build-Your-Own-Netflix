from flask import Flask, render_template, Response
import boto3
import os

app = Flask(__name__)

S3_BUCKET = os.environ["S3_BUCKET"]
AWS_REGION = os.environ["AWS_REGION"]
s3_client = boto3.client("s3", region_name=AWS_REGION)

@app.route("/")
def index():
    # List objects in the transcoded bucket
    response = s3_client.list_objects_v2(Bucket=S3_BUCKET)
    videos = [obj["Key"] for obj in response.get("Contents", [])]
    return render_template("index.html", videos=videos)

@app.route("/stream/<path:key>")
def stream(key):
    # Generate a pre-signed URL for streaming
    url = s3_client.generate_presigned_url(
        "get_object",
        Params={"Bucket": S3_BUCKET, "Key": key},
        ExpiresIn=3600
    )
    return Response(
        f'<video controls><source src="{url}" type="video/mp4"></video>',
        mimetype="text/html"
    )

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)