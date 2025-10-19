# Implementação de Stack AWS CloudFormation - Cash Out via Pix

Este repositório contém a definição e automação da **implantação de uma stack AWS CloudFormation**, responsável por orquestrar o fluxo de uma transação financeira de **Cash Out via Pix** usando **AWS Step Functions** e **AWS Lambda**.

## Visão Geral

A stack define uma **State Machine (Máquina de Estados)** que gerencia todo o fluxo de uma transação Pix, incluindo validação, checagem de saldo, execução e tratamento de falhas. O modelo está escrito em **YAML** usando **CloudFormation** para provisionar a infraestrutura necessária.

---

## Estrutura do Repositório

```bash
.
├── templates/
│   └── state-machine.yaml         # Template principal da Stack (Step Functions)
├── parameters/
│   └── sa-east-1.json             # Arquivo de parâmetros com ARNs das Lambdas
├── scripts/
│   └── deploy.sh                  # Script de deploy automatizado via AWS CLI
└── README.md

```

## O que é o AWS CloudFormation?
O AWS CloudFormation é um serviço da AWS que permite definir e provisionar a infraestrutura da nuvem por meio de arquivos de modelo em YAML ou JSON. Isso garante automação, versionamento e reprodutibilidade de ambientes.

---

## Arquitetura da Stack
A stack provisiona uma State Machine (Step Functions) com as seguintes etapas, cada uma representando uma fase do fluxo de transação:

1. `ValidarSolicitacao`: Valida a solicitação do Pix.
2. `ChecarSaldo`: Verifica o saldo da conta de origem.
3. `TemSaldo`? (Condicional):
- Sim → `DeduzirSaldo`
- Não/Falha → `RegistrarFalha`
4. `DeduzirSaldo`: Reserva ou debita o saldo.
5. `ExecutarPix`: Chama API de execução do Pix.
6. `ErroNaAPIPix?` (Condicional):
- Sim → `EstornarSaldo`
- Não → `NotificarCliente`
7. `EstornarSaldo`: Reverte o débito em caso de erro.
8. `NotificarCliente`: Envia notificação de sucesso.
9. `RegistrarFalha`: Loga falhas de qualquer etapa.
10. `RegistrarTransacao`: Registra o status final da transação.

⚙️ Nota: As funções Lambda e a Role de execução da Step Function devem ser criadas previamente. Este stack assume que os ARNs dessas funções estão disponíveis e serão passados via parâmetros.

___

## Implantação da Stack
### Pré-requisitos
- Conta AWS ativa e configurada.
- AWS CLI instalado e autenticado (`aws configure`).
- `jq` (opcional): para processamento de parâmetros.
- As funções AWS Lambda referenciadas no template já devem estar criadas, assim como a IAM Role usada pela Step Function.

---

## 1. Configurar Parâmetros
Abra o arquivo `parameters/sa-east-1.json` e substitua os valores `<SEU_ID_DE_CONTA>` pelos ARNs reais das funções Lambda e Role IAM.

Exemplo de parâmetro:

```json
[
  {
    "ParameterKey": "ValidarSolicitacaoFunctionArn",
    "ParameterValue": "arn:aws:lambda:sa-east-1:123456789012:function:ValidarSolicitacao"
  }
]

```

## 2. Implantar Stack via Script

Execute o script de deploy:

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

Esse script irá:
- Validar os parâmetros
- Executar o `aws cloudformation deploy`
- Exibir a saída da stack

## Próximos Passos
- Criar as funções Lambda necessárias (se ainda não existirem)
- Customizar a lógica de negócios dentro das funções Lambda
- Adicionar monitoramento (CloudWatch Logs, Alarms)
- Automatizar testes com AWS SAM ou LocalStack

## Repositório Relacionado

Este repositório é parte de uma solução completa para o fluxo de Cash Out via Pix.

Para ver a documentação detalhada do **workflow automatizado (State Machine)** e entender cada etapa lógica da orquestração, acesse:

👉 [Workflow Automatizado - Cash Out via Pix](https://github.com/agatacustodio/desafio-cloudformation.git)
