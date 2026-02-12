import json
import datetime
import os 

def generate_incident_report(error_message, error_type):
    incident_data = {
        "timestamp" : datetime.datetime.now().isoformat(),
        "status" : "CRITICAL",
        "error_type" : error_type,
        "message" : error_message,
        "environment" : "DevOps-training",
        "system_id" : "Seat-Brain-01" 
    }

    filename = "incident-report.json"
    with open(filename, 'w') as f:
        json.dump(incident_data, f, indent=4)
    print(f"⚠️ Incident report generated: {filename}")

#Simulacion de un fallo de sistema
try:
    print("Checking Seat Brain system health...")
    # Simulacion de error de conexión o memoria
    raise ConnectionError("Database connection timed out after 30s")
except Exception as e:
    generate_incident_report(str(e), type(e).__name__)