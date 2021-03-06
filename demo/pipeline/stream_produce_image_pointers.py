"""
Produces pointers to images in S3 to a Kafka Topic.
Each pointer contains the information necessary for a downstream
consumer to retrieve the specific image from S3.
"""

from argparse import ArgumentParser
from kafka import KafkaProducer
from time import time
from tqdm import tqdm
import boto3
import json
import pdb


def S3Pointer(id, s3_bucket, s3_key):
    return dict(id=id, s3_bucket=s3_bucket, s3_key=s3_key)


if __name__ == "__main__":

    ap = ArgumentParser(description="See script")
    ap.add_argument("--bucket", help="S3 bucket name",
                    default="klibisz-twitter-stream")
    ap.add_argument("--kafka_pub_topic",
                    help="Topic to which image events get published",
                    default="aknn-demo.image-pointers")
    ap.add_argument("--kafka_server",
                    help="Bootstrap server for producer",
                    default="ip-172-31-19-114.ec2.internal:9092")
    ap.add_argument("-b", "--batch_size", type=int, default=1000,
                    help="Size of batches produced")

    args = vars(ap.parse_args())

    bucket = boto3.resource("s3").Bucket(args["bucket"])
    producer = KafkaProducer(
        bootstrap_servers=args["kafka_server"],
        compression_type="gzip",
        key_serializer=str.encode,
        value_serializer=str.encode)

    t0 = time()
    nb_produced = 0
    batch = []
    for obj in bucket.objects.all():

        # TODO: this was a bad design in the ingestion.
        # There should be a way to distinguish statues
        # from images without ever reading in the statuses.
        if obj.key.endswith(".json.gz"):
            continue

        batch.append(S3Pointer(
            id=obj.key.split('.')[0],
            s3_bucket=obj.bucket_name, s3_key=obj.key))

        if len(batch) < args["batch_size"]:
            continue

        key = "batch-%s-%s" % (batch[0]['id'], batch[-1]['id'])
        value = json.dumps(batch)
        producer.send(args["kafka_pub_topic"], key=key, value=value)
        nb_produced += len(batch)
        batch = []

        print("%d produced - %d / second" % (
            nb_produced, nb_produced / (time() - t0)))
