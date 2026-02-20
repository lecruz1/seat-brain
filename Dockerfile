# Usamos la imagen base de AWS para Python
FROM public.ecr.aws/lambda/python:3.9

# Establecemos el directorio de trabajo (donde Lambda busca el código)
WORKDIR ${LAMBDA_TASK_ROOT}

# 1. Copiamos el archivo de requerimientos 
COPY requirements.txt .

# 2. Instalamos las librerías
RUN pip install -r requirements.txt

# 3. COPIAMOS EL ARCHIVO DESDE LA CARPETA SRC
COPY src/lambda_function.py .

# 4. Establecemos el manejador
CMD [ "lambda_function.lambda_handler" ]