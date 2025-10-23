# Implementação de Stack AWS CloudFormation - Cash Out via Pix

Este repositório contém a definição e automação da **implantação de uma Stack AWS CloudFormation**, responsável por orquestrar o fluxo de uma transação financeira de **Cash Out via Pix** usando **AWS Step Functions** e **AWS Lambda**.

## O que é uma Stack AWS CloudFormation?

Uma Stack AWS CloudFormation é um conjunto de recursos da AWS que são gerenciados como uma única unidade, baseada em um template. Esse template, escrito em JSON ou YAML, descreve os recursos e suas dependências, como instâncias EC2, bancos de dados RDS e redes VPC. O CloudFormation usa o template para criar, atualizar e excluir todos os recursos da stack de forma consistente e automatizada. 

---

## Implantação da Stack
### Pré-requisitos
- Conta AWS ativa e configurada.
- AWS CLI instalado e autenticado (`aws configure`).
- `jq` (opcional): para processamento de parâmetros.
- As funções AWS Lambda referenciadas no template já devem estar criadas, assim como a IAM Role usada pela Step Function.

---

## Stack Implementada
A Stack definida no arquivo `cloudformation-template.yaml` cria um fluxo de trabalho orquestrado para a funcionalidade de *Cash Out via Pix*, o qual inclui validação, checagem de saldo, execução e tratamento de falhas. O modelo está escrito em **YAML** usando **CloudFormation** para provisionar a infraestrutura necessária.

## Serviço Principal
- AWS Step Functions: Criação da State Machine chamada `CashOutViaPix`.

## Arquitetura da Stack
A State Machine orquestra uma série de passos de processamento, incluindo lógica de decisão e tratamento de falhas, conforme o diagrama de fluxo (baseado na definição em YAML):

| Estado | Tipo | Ação/Recurso (Lambda) | Lógica |
|--------|------|-----------------------|--------|
| StartAt: `ValidarSolicitacao` | `Task` | `${ValidarSolicitacaoFunctionArn}` | Inicia o fluxo. |
| `ChecarSaldo` | `Task` | `${ChecarSaldoFunctionArn}` | - |
| `TemSaldo?` | `Choice` | - | Decisão: Se tiver saldo, vai para `DeduzirSaldo`. Senão, vai para `RegistrarFalha`. |
| `DeduzirSaldo` | `Task` | `${DeduzirSaldoFunctionArn}` | - |
| `ExecutarPix` | `Task` | `${ExecutarPixFunctionArn}` | Tratamento de Falhas: Em caso de falha, captura o erro (`States.TaskFailed`) e vai para `EstornarSaldo`. |
| `EstornarSaldo` | `Task` | `${EstornarSaldoFunctionArn}` | Chamado apenas se o `ExecutarPix` falhar. |
| `NotificarCliente`, | `Task` | `${NotificarClienteFunctionArn}` | Chamado após o sucesso do `ExecutarPix`. |
| `RegistrarTransacao` | `Task` | `${RegistrarTransacaoFunctionArn}` | Chamado após o sucesso do `NotificarCliente`. |
| Sucesso: `Sucesso` | `Succeed` | - | Fim do fluxo de sucesso. |
| `FalhaNoPix` | `Task` | `${RegistrarFalhaFunctionArn}` | Chamado após o `EstornarSaldo`. |
| `RegistrarFalha` | `Task` | `${RegistrarFalhaFunctionArn}` | Chamado pelo Choice (`TemSaldo?`) quando não há saldo. |
| Falha: `Falha` | `Fail` | - | Fim do fluxo de falha. |

---

## Repositório Relacionado

Este repositório é parte de uma solução completa para o fluxo de Cash Out via Pix.

Para ver a documentação detalhada do **workflow automatizado (State Machine)** e entender cada etapa lógica da orquestração, acesse:

👉 [Workflow Automatizado - Cash Out via Pix](https://github.com/agatacustodio/desafio-cloudformation.git)
