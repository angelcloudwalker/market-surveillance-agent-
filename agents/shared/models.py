from strands.models import BedrockModel

# Desarrollo y pruebas — cambiar a Sonnet para pruebas serias
MODEL = BedrockModel(
    model_id="us.amazon.nova-micro-v1:0",
    max_tokens=4096,
)
# MODEL = BedrockModel(
#     model_id="us.anthropic.claude-sonnet-4-5",
#     max_tokens=8192,
# )
