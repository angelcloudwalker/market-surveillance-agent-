FROM public.ecr.aws/bedrock-agentcore/runtime:latest

WORKDIR /app

# Dependencias
COPY pyproject.toml .
RUN pip install --no-cache-dir "strands-agents>=1.40.0" "bedrock-agentcore" "psycopg2-binary"

# Código del agente
COPY handler.py .
COPY tools/ tools/
COPY skills/ skills/

# shared/ — db.py, models.py, scoring.py, adapters/
COPY ../../shared/ shared/

ENV DB_PORT=5432
ENV DB_NAME=market_surveillance
# Se inyecta en deploy: agentcore deploy --env AGENT_RUNTIME_ARN=arn:...
ENV AGENT_RUNTIME_ARN=""

ENTRYPOINT ["python", "handler.py"]
