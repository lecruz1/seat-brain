import boto3
import panda as pd 
import os
from datetime import datetime
import io

def lambda_handler(event, context):
    bucket_name = os.environ.get('BUCKET_NAME')

    data = {
        'Incident_ID': [101, 102, 103],
        'System': ['Engine', 'Brakes', 'Infotainment'],
        'Severity': ['High', 'Critical', 'Low'],
        'Timestamp': [datetime.now().strftime("%Y-%m-%d %H:%M:%S")] * 3
    }

    df = pd.DataFrame(data)

    csv_buffer = io.StringIO()
    df.to_csv(csv_buffer, index=False)

    s3 = boto3.client('s3')
    file_name = f"reports/lambda_incident_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"

    s3.put_object(
        Bucket=bucket_name,
        Key=file_name,
        Body=csv_buffer.getvalue()
    )

    return {
        'statusCode': 200,
        'body': f"Archivo {file_name} creado exitosamente en {bucket_name}"
    }