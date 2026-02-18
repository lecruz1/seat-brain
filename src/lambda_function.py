import boto3
import pandas as pd 
import os
from datetime import datetime
import io

def lambda_handler(event, context):
    # 1. Recuperar variables de entorno
    bucket_name = os.environ.get('BUCKET_NAME')
    sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
    
    # Clientes de AWS
    s3 = boto3.client('s3')
    sns = boto3.client('sns')

    # 2. Generación de datos simulados
    data = {
        'Incident_ID': [101, 102, 103],
        'System': ['Engine', 'Brakes', 'Infotainment'],
        'Severity': ['High', 'Critical', 'Low'],
        'Timestamp': [datetime.now().strftime("%Y-%m-%d %H:%M:%S")] * 3
    }
    df = pd.DataFrame(data)

    # 3. Lógica de Notificación: Filtrar incidentes graves
    # Buscamos si hay algo 'Critical' o 'High'
    critical_incidents = df[df['Severity'].isin(['Critical', 'High'])]
    
    if not critical_incidents.empty:
        # Creamos un resumen rápido para el cuerpo del correo
        summary = critical_incidents[['Incident_ID', 'System', 'Severity']].to_string(index=False)
        
        sns.publish(
            TopicArn=sns_topic_arn,
            Subject=f"⚠️ ALERTA: Incidentes Críticos Detectados - {datetime.now().strftime('%Y-%m-%d')}",
            Message=(
                f"Se han detectado incidentes que requieren atención inmediata:\n\n"
                f"{summary}\n\n"
                f"El reporte completo ha sido guardado en el bucket: {bucket_name}"
            )
        )

    # 4. Convertir a CSV y subir a S3
    csv_buffer = io.StringIO()
    df.to_csv(csv_buffer, index=False)

    file_name = f"reports/lambda_incident_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"

    s3.put_object(
        Bucket=bucket_name,
        Key=file_name,
        Body=csv_buffer.getvalue()
    )

    return {
        'statusCode': 200,
        'body': f"Reporte {file_name} generado. Notificaciones enviadas si aplicaba."
    }