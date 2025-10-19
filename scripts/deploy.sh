#!/bin/bash

# Nome da stack
STACK_NAME="cash-out-pix-state-machine"

# Região
REGION="sa-east-1"

# Caminho para o template e parâmetros
TEMPLATE_FILE="templates/state-machine.yaml"
PARAMETERS_FILE="parameters/sa-east-1.json"

echo "Iniciando deploy da stack: $STACK_NAME"
echo "Região: $REGION"
echo "Template: $TEMPLATE_FILE"
echo "Parâmetros: $PARAMETERS_FILE"

# Verifica se os arquivos existem
if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "❌ Template não encontrado: $TEMPLATE_FILE"
  exit 1
fi

if [ ! -f "$PARAMETERS_FILE" ]; then
  echo "❌ Parâmetros não encontrados: $PARAMETERS_FILE"
  exit 1
fi

# Comando de deploy
aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$TEMPLATE_FILE" \
  --parameter-overrides $(cat "$PARAMETERS_FILE" | jq -r '.[] | "\(.ParameterKey)=\(.ParameterValue)"') \
  --capabilities CAPABILITY_NAMED_IAM \
  --region "$REGION"

if [ $? -eq 0 ]; then
  echo "✅ Stack '$STACK_NAME' implantada com sucesso."
else
  echo "❌ Falha na implantação da stack."
  exit 1
fi
