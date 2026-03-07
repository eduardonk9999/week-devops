# week-devops



A teoria é linda, mas DevOps se faz no terminal. Abaixo, temos um passo a passo para você sentir o que discutimos hoje na pele.

Parte 1: O Raio-X do Linux com strace
Vamos criar uma situação simulando uma aplicação que tenta ler um arquivo que não existe e entender como o Linux enxerga isso.

Abra o seu terminal Linux (pode ser WSL no Windows, Linux nativo ou Cloud Shell).
Tente ler um arquivo inexistente usando o comando cat:
cat arquivo_secreto.txt
Resultado esperado: cat: arquivo_secreto.txt: No such file or directory

A Mágica do strace: Agora vamos ver como o Sistema Operacional processou isso. Rode:
strace cat arquivo_secreto.txt
Analise a saída. Em meio a várias linhas, você encontrará algo parecido com: openat(AT_FDCWD, "arquivo_secreto.txt", O_RDONLY) = -1 ENOENT (No such file or directory)
Por que isso importa? O strace interceptou a chamada de sistema (openat) que o comando cat fez ao Kernel pedindo para ler o arquivo. O Kernel respondeu com o código de erro -1 ENOENT (Error No Entry). Quando uma aplicação travou em produção sem motivo aparente, o strace mostra exatamente em qual chamada ela congelou.

Parte 2: O Poder do Terraform na Prática
Vamos criar nossa primeira infraestrutura como código! Para facilitar e não depender de contas na nuvem, vamos usar um provedor local do Terraform.

Instale o Terraform: Siga as instruções em developer.hashicorp.com/terraform/install.
Crie um diretório para o projeto e entre nele:
mkdir meu-primeiro-terraform && cd meu-primeiro-terraform
Crie o arquivo de configuração main.tf:
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
  }
}

resource "local_file" "servidor_falso" {
  content  = "Esta é a minha infraestrutura provisionada pelo Terraform. O estado (State) está me vigiando!"
  filename = "${path.module}/servidor.txt"
}
Inicie o Terraform (init): terraform init - Leu o seu código e baixou os plugins necessários.
Planeje a Mudança (plan): terraform plan - Verificou a realidade vs o código. Exibe + create.
Aplique a Mudança (apply): terraform apply - Digite yes. O arquivo servidor.txt será criado!
A Mágica do Estado: Apague manualmente o arquivo com rm servidor.txt, rode terraform plan novamente e veja o Terraform alertar que precisa recriá-lo.
Destrua Tudo (destroy): terraform destroy para limpar o laboratório.
Próximos Passos
O chão está concretado. Você entende o Sistema Operacional e sabe que não se clica em painel.

Amanhã nós vamos empacotar nossa aplicação. A era heroica do sysadmin que instalava pacotes na mão passou.

Tema do Dia 3: Containers e Orquestração para Engenharia da Escala

(Spoiler: Você vai descobrir a maior mentira da internet: de que Kubernetes é mágica. Kubernetes é Linux).

Aviso: Traga capacete amanhã. O atrito vai aumentar.

Docker Compose =>
É um arquivo em que eu faco a definicao do meu app, dentro dele
eu coloco uma orquestracao de containers front, back e banco
e ele mesmo faz a conexao de todos
os containers.

Se você disser "Vou entrar no container" para uma pessoa engenheira sênior de verdade, ela vai rir. Sabe por quê?

Porque Container não existe.

Não existe um "objeto físico" ou uma máquina virtual chamada container. O que chamamos de container é apenas uma aplicação rodando no Linux, sobre a qual o Kernel aplicou duas "táticas de ilusão":

Namespaces (A Ilusão da Solidão):

O Linux engana a sua aplicação. Ele cria um namespace isolado e diz para o seu processo: "Você é o único que existe nesta máquina, você é o PID 1 (Process ID 1), você tem a sua própria placa de rede". A aplicação acredita e roda isolada.

Cgroups (A Coleira de Recursos):

Os Control Groups (Cgroups) limitam o uso de recursos de um processo. Você diz: "Essa aplicação só pode usar 500MB de RAM e meia CPU". Se ela tentar usar 501MB, o Kernel do Linux puxa a coleira.

Quando você junta Namespaces + Cgroups + um sistema de arquivos isolado (Rootfs) = O mercado decidiu chamar isso de "Container".

Subir 5 containers no seu notebook (usando Docker ou Podman) é fácil.

Mas como você gerencia 5.000 containers distribuídos em 100 servidores (Nodes)? Se um servidor queimar a fonte de energia de madrugada, quem move os containers dele para os outros 99 servidores que ainda estão vivos?

Isso é Orquestração. E o rei da orquestração é o Kubernetes (K8s).

O Cérebro (Control Plane) e os Trabalhadores (Worker Nodes)
O Kubernetes é dividido em duas grandes partes:

Control Plane: É a gerência. Ele não roda a sua aplicação. Ele guarda anotações (etcd), decide onde os containers vão rodar (scheduler) e expõe uma recepção para você falar com ele (API Server).

Worker Nodes: São os servidores braçais. Lá roda a sua aplicação.

O Soldado do Linux: Kubelet
Em cada Worker Node, roda um processo chamado Kubelet. Ele é quem recebe as ordens da gerência e fala pro Sistema Operacional (Linux): "Cria um Namespace e um Cgroup aqui pra essa aplicação rodar".

O Superpoder: Desired State (Estado Desejado)
O K8s trabalha com um conceito chamado Loop de Reconciliação.

Você não diz para ele: "Crie 3 cópias do meu site".

Você diz (Declarativo): "O Estado Desejado é existirem 3 cópias".

O Kubernetes então entra num loop infinito de observação:

Quantos sites eu tenho agora? 1.
Qual é o desejo? 3.
Ação: O Kubernetes manda o Kubelet subir mais 2 para empatar a realidade com o Desejo.

Kubernets => Orquestracao de containers K8s

Clusters => Um conjunto de servidores.

Pod => é um ecosistema, vai ter um IP, um container, e outras infos, um pod ele é menor unidade.
No K8s quanda pecinha, cada coisa chamamos de node.
Dentro de um POD eu posso ter mais de um container.

ETCD => Banco de Dados do k8S

Pipeline => Cano, vc tem uma sequencia de coisas que vai passar por ele.

CI - CD
GitHub
GitLab
Tudo isso é CI - Continus integration =>
Neles a gente configura uma pipeline,
e o codigo vai comecar passar por staps,
Ex: Teste de código, Teste unitarios, com isso temos uma qualidade de código antes de de finalizar o deploy.
Tudo isso é CD - Continus Delivery =>
Deploy, QA, Homolog, Prod....

Uma pessoa desenvolvedora pode escrever o código mais genial, limpo e rápido do mundo. Se esse código ficar commitado no repositório (Git) por semanas, esperando uma "janela de deploy" no sábado à noite, esse código não entregou valor nenhum para o cliente da empresa.

Antigamente, juntava-se o trabalho de 50 pessoas desenvolvedoras durante 3 meses para fazer um "Grande Release". O resultado?

O Merge Hell (Inferno da Mesclagem). O sistema quebrava inteiro porque as peças não encaixavam.

1. A Cura: CI (Continuous Integration / Integração Contínua)
A regra de ouro moderna é: Integração Pequena e Frequente.

Ao invés de esperar 3 meses, a pessoa desenvolvedora envia código para o repositório principal 5 vezes por dia.

O CI é um pipeline (esteira automatizada) que funciona como um "Inspetor de Qualidade". Toda vez que código novo entra, a esteira (ex: GitHub Actions, GitLab CI):

1. Baixa o código
2. Roda a compilação (Build)
3. Roda Testes Unitários e de Integração: Garante que o recurso novo não quebrou o carrinho de compras antigo.
4. Verifica Segurança (Sec): Checa se existem senhas chumbadas no código ou bibliotecas com vulnerabilidades conhecidas (CVEs).
5. Empacota (Docker Build): Cria a imagem nova do Container e armazena no registro (Docker Hub, AWS ECR).
Se qualquer etapa falhar, a esteira fica VERMELHA e bloqueia a entrega. Nós resolvemos problemas enquanto eles são pequenos.

2. O Destino: CD (Continuous Delivery/Deployment)
A imagem do Container está pronta. Agora ela precisa chegar na Produção (no cluster Kubernetes).

Fazer Deploy manualmente, trocando a versão no painel e torcendo para funcionar, é a definição de amadorismo.

CD é ter a infraestrutura automatizada puxando ou aplicando a versão nova de forma invisível para quem usa.

O Fim do Medo da Sexta-Feira! (Estratégias de Deploy Seguras):

Rollback em 1 clique: Se o Deploy quebrar a produção, nós não consertamos na produção. Nós voltamos para a versão anterior (git revert / ArgoCD sync) em segundos.

Canary Release (Canário): Não atualiza tudo de uma vez. Manda 5% do tráfego para a versão Nova. Observa. Se estiver dando erro, volta. Se estiver bom, aumenta para 20%, depois 100%. Ninguém percebeu.

CLAUDE
Você já ouviu "coloca na Cloud" como se fosse apertar um botão mágico. Mas a Cloud é uma infraestrutura real, com servidores físicos em data centers espalhados pelo planeta. Entender como ela funciona é o que separa quem "usa" de quem domina.

1. O que é Cloud Computing de Verdade?
Cloud é alugar computação, armazenamento e rede de outra empresa (AWS, GCP, Azure) sob demanda, pagando pelo que usar. Simples assim.

A mágica não é "onde" roda, mas como roda:

Elasticidade: Escala de 2 para 200 máquinas automaticamente quando o tráfego da Black Friday chega. E volta para 2 quando acaba. Sem ligar para o data center pedindo servidor.
Pay-as-you-go: Pagou por 3 horas de GPU para treinar um modelo? Desligou? Parou de pagar.
Disponibilidade Global: Sua aplicação pode rodar simultaneamente em São Paulo, Virginia e Frankfurt.
2. A Anatomia: Regiões e Zonas de Disponibilidade
Imagine a AWS como uma rede de shopping centers pelo mundo:

Região (Region): Uma cidade inteira (ex: sa-east-1 = São Paulo). Cada região tem múltiplos data centers.
Zona de Disponibilidade (AZ): Cada data center isolado dentro da região. Se um pegar fogo, os outros continuam operando.
Regra de ouro: Nunca rode tudo numa AZ só. Distribua seus Pods/instâncias em pelo menos 2 AZs. Assim, se uma cair, sua aplicação continua no ar.

3. IaaS vs PaaS vs SaaS — O Modelo de Responsabilidade
Quanto mais alto o nível do serviço, menos você gerencia (e menos controle tem):

| Modelo | Você gerencia | Exemplo | |--------|--------------|---------| | IaaS (Infrastructure as a Service) | OS, runtime, app, dados | EC2, GCE, Azure VMs | | PaaS (Platform as a Service) | Apenas app e dados | Heroku, Cloud Run, App Engine | | SaaS (Software as a Service) | Nada (só usa) | Gmail, Slack, Notion |

Para DevOps, o sweet spot geralmente é entre IaaS e PaaS: Kubernetes gerenciado (EKS, GKE, AKS). Você controla os containers, mas não precisa instalar o cluster na mão.

4. Serviços Gerenciados: Não Reinvente a Roda
A Cloud oferece serviços prontos para problemas comuns:

Banco de Dados: RDS (PostgreSQL/MySQL gerenciado), DynamoDB (NoSQL)
Armazenamento: S3 (objetos/arquivos), EBS (disco de VM)
Mensageria: SQS (filas), SNS (notificações), EventBridge
Container Registry: ECR (AWS), GCR (Google) — onde suas imagens Docker ficam guardadas
DNS e CDN: Route53 + CloudFront (AWS), Cloud DNS + Cloud CDN (Google)
A regra: Se a Cloud oferece gerenciado, use gerenciado. Rodar seu próprio PostgreSQL numa EC2 é pedir para ter pesadelo com backup, patching e failover.

5. Custo: O Monstro Silencioso
A Cloud cobra por tudo: CPU, RAM, tráfego de rede (especialmente saída!), armazenamento, até DNS queries.

Dicas de sobrevivência financeira:

Tags: Marque todos os recursos com projeto/time/ambiente. Sem tags = sem controle de custo.
Alertas de billing: Configure alarmes para gastar mais que X reais/mês.
Spot/Preemptible instances: VMs até 90% mais baratas, mas a Cloud pode tomá-las de volta a qualquer momento. Perfeitas para workloads stateless com Kubernetes.
Reserved Instances / Committed Use: Comprometa-se por 1-3 anos e economize 40-70% vs on-demand.
6. Cloud + Kubernetes + CI/CD = O Trinômio Moderno
O fluxo real de uma empresa moderna:

Terraform provisiona o cluster Kubernetes na Cloud (EKS/GKE/AKS)
CI/CD (GitHub Actions) builda a imagem Docker e faz push para o Container Registry
Kubernetes no cluster Cloud recebe o deploy e distribui entre as AZs
Auto-scaling ajusta o número de Pods e Nodes conforme a demanda
Isso é o que estamos montando ao longo da semana. Cada dia foi uma peça desse quebra-cabeça.


Objetivo do Dia
Construir, containerizar, deployar e automatizar uma aplicacao web completa, do git push ao Load Balancer publico na AWS.

Voce sobreviveu a semana inteira. Linux, Terraform, Containers, Kubernetes, Cloud, CI/CD, tudo foi estudado de forma isolada, como pecas de um quebra-cabeca. Hoje acabou a teoria. Nos vamos montar o Transformer.

O que vamos usar
Ferramenta	Para que
Node.js	Aplicacao backend (API)
Docker	Empacotar a aplicacao
EKS (eksctl)	Cluster Kubernetes na AWS
kubectl	Gerenciar o cluster
GitHub Actions	Pipeline CI/CD automatizada
Docker Hub	Registro de imagens
A Aplicacao: Semana DevOps Map
Uma app interativa onde cada participante se cadastra com Nome, Localizacao e Cargo/Area. A app mostra em tempo real:

Mapa interativo com pontos nos estados/paises dos participantes
Painel de estatisticas (total, distribuicao por cargo)
Feed ao vivo mostrando quem acabou de se cadastrar
Nome do Pod que serviu cada requisicao (pra provar o balanceamento de carga!)
Estrutura do Projeto
dia5/
├── app/                          # Aplicacao
│   ├── server.js                 # Backend Express (API REST)
│   ├── Dockerfile                # Container (multi-stage build)
│   └── public/                   # Frontend interativo
├── k8s/                          # Manifestos Kubernetes
│   ├── namespace.yaml
│   ├── deployment.yaml           # 3 replicas, probes, resource limits
│   ├── service.yaml              # LoadBalancer
│   └── hpa.yaml                  # Auto-scaling (3 a 10 pods)
├── eks/
│   └── cluster.yaml              # Configuracao do cluster EKS
└── .github/workflows/
    └── ci.yaml                   # Pipeline CI/CD
As Rotas da API
Metodo	Rota	O que faz
GET	/	Serve o frontend (HTML)
GET	/healthz	Health check (usado pelo K8s)
POST	/api/participante	Cadastra um participante
GET	/api/participantes	Lista todos
GET	/api/stats	Estatisticas agregadas
GET	/api/info	Info do app (versao, pod, uptime)

Entendendo o Dockerfile (Multi-Stage Build)
# Stage 1: Instalar dependencias (imagem temporaria)
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --only=production && npm cache clean --force

# Stage 2: Imagem final (so o necessario)
FROM node:20-alpine AS production
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY server.js ./
COPY public/ ./public/
RUN chown -R appuser:appgroup /app
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
CMD wget --no-verbose --tries=1 --spider http://localhost:3000/healthz || exit 1
CMD ["node", "server.js"]
Conceitos importantes:

Multi-stage build: imagem final nao tem instaladores nem cache
Alpine: imagem base leve (~5MB vs ~1GB do Ubuntu)
Non-root user: nunca rode como root dentro do container!
HEALTHCHECK: Docker sabe se a app esta saudavel
Buildando e Rodando
# Build da imagem
docker build -t devops-map-brasil:v1 .

# Rodar em background
docker run -d --name devops-map -p 3000:3000 devops-map-brasil:v1

# Testar
curl http://localhost:3000/healthz
curl -X POST http://localhost:3000/api/participante \
  -H "Content-Type: application/json" \
  -d '{"nome":"Jeferson","estado":"SP","cargo":"DevOps"}'
A imagem final tem ~180MB (Alpine + Node + App). Compare com node:20 (>1GB).

Subindo para o Docker Hub
docker login
docker tag devops-map-brasil:v1 SEU_USER/devops-map-brasil:v1
docker tag devops-map-brasil:v1 SEU_USER/devops-map-brasil:latest
docker push SEU_USER/devops-map-brasil:v1
docker push SEU_USER/devops-map-brasil:latest
Troque SEU_USER pelo seu usuario do Docker Hub!

Cluster EKS e Deploy no Kubernetes
Criando o Cluster EKS
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: semana-devops
  region: us-east-1
  version: "1.31"
managedNodeGroups:
  - name: workers
    instanceType: t3.medium
    desiredCapacity: 2
    minSize: 1
    maxSize: 4
    volumeSize: 20
# Criar o cluster (~15-20 minutos)
eksctl create cluster -f dia5/eks/cluster.yaml

# Verificar
kubectl get nodes
Aplicando os Manifestos
# Editar deployment.yaml e trocar <SEU_DOCKERHUB_USER>

# Aplicar na ordem
kubectl apply -f dia5/k8s/namespace.yaml
kubectl apply -f dia5/k8s/deployment.yaml
kubectl apply -f dia5/k8s/service.yaml
kubectl apply -f dia5/k8s/hpa.yaml
Verificando o Deploy
# Ver os pods (3 replicas!)
kubectl get pods -n semana-devops

# Ver o Service e pegar o EXTERNAL-IP
kubectl get svc -n semana-devops
Output esperado:

NAME                TYPE           CLUSTER-IP    EXTERNAL-IP                           PORT(S)
devops-map-brasil   LoadBalancer   10.100.x.x    aXXX.us-east-1.elb.amazonaws.com     80:31234/TCP
Acesse o EXTERNAL-IP no navegador! A app esta no ar na AWS!

Testando o Balanceamento de Carga
Faca varios cadastros e observe o campo "Pod" no feed. Cada requisicao pode ser servida por um pod diferente!

for i in $(seq 1 10); do
  curl -s http://EXTERNAL_IP/api/info | jq .pod
done

CI/CD com GitHub Actions
O Pipeline
┌──────────┐    ┌───────────────┐    ┌─────────────┐
│   Test   │───>│   Build &     │───>│   Deploy     │
│  & Lint  │    │    Push       │    │   no EKS     │
└──────────┘    └───────────────┘    └─────────────┘
Test & Lint roda os testes e verifica o codigo
Build & Push builda a imagem Docker e sobe pro Docker Hub
Deploy atualiza a imagem no cluster EKS
Configurando os Secrets
No seu repositorio GitHub, va em Settings > Secrets and variables > Actions:

Secret	Valor
DOCKERHUB_USERNAME	Seu usuario do Docker Hub
DOCKERHUB_TOKEN	Token de acesso (nao a senha!)
AWS_ACCESS_KEY_ID	Chave de acesso AWS
AWS_SECRET_ACCESS_KEY	Secret da chave AWS
NUNCA coloque credenciais direto no codigo. Use Secrets sempre!

Primeiro Deploy Automatizado
# Fazer uma alteracao na app
# Edite server.js e mude APP_VERSION para "2.0.0"

# Commit e push
git add .
git commit -m "feat: deploy v2 do Semana DevOps Map"
git push origin main
Acompanhe o pipeline na aba Actions do repositorio!

Engenharia do Caos
Hora de quebrar as coisas propositalmente e ver o Kubernetes se curar sozinho.

Deletando Pods
kubectl delete pods -n semana-devops -l app=devops-map-brasil

# Imediatamente veja o K8s recriando:
kubectl get pods -n semana-devops -w
Os pods novos sobem em SEGUNDOS. Isso e o Loop de Reconciliacao: o K8s viu que a realidade (0 pods) era diferente do estado desejado (3 pods) e agiu.

Simulando OOMKill
# Dar muito pouca memoria (forcar OOMKill)
kubectl set resources deployment/devops-map-brasil \
  -n semana-devops --limits=memory=10Mi

# STATUS = OOMKilled > CrashLoopBackOff
# Isso e o KERNEL DO LINUX matando o processo que violou o cgroup!

# Corrigir:
kubectl set resources deployment/devops-map-brasil \
  -n semana-devops --limits=memory=256Mi --requests=memory=128Mi
Rolling Update sem Downtime
kubectl set image deployment/devops-map-brasil \
  devops-map-brasil=SEU_USER/devops-map-brasil:v2 -n semana-devops

kubectl rollout status deployment/devops-map-brasil -n semana-devops

# Deu ruim? ROLLBACK instantaneo!
kubectl rollout undo deployment/devops-map-brasil -n semana-devops
Comandos Uteis
# Descrever pod (eventos, erros)
kubectl describe pod <NOME_DO_POD> -n semana-devops

# Shell dentro do container
kubectl exec -it <NOME_DO_POD> -n semana-devops -- sh

# Ver eventos do namespace
kubectl get events -n semana-devops --sort-by=.metadata.creationTimestamp

# HPA
kubectl get hpa -n semana-devops

# Uso de recursos
kubectl top pods -n semana-devops
Limpeza (IMPORTANTE!)
Para nao tomar um susto na fatura da AWS, delete o cluster apos a aula!

kubectl delete -f dia5/k8s/
eksctl delete cluster -f dia5/eks/cluster.yaml --disable-nodegroup-eviction


