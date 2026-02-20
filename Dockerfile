# Usamos la imagen base de AWS para Python
FROM public.ecr.aws/lambda/python:3.9

# Copiamos el archivo de requerimientos
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Instalamos las librerías (Pandas, etc.)
RUN pip install -r requirements.txt

# Copiamos el código de la función
COPY lambda_function.py ${LAMBDA_TASK_ROOT}

# Establecemos el manejador (handler)
CMD [ "lambda_function.lambda_handler" ]