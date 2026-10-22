<p align="center">
  <img src="assets/avant_logo.png" alt="AVANT — UFMG Flying Robots Competition Team" width="320" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/ROS%202-Humble-22314E?style=for-the-badge&logo=ros&logoColor=white" height="25" />
  <img src="https://img.shields.io/badge/Gazebo-Classic%2011-F79A1E?style=for-the-badge" height="25" />
  <img src="https://img.shields.io/badge/ArduPilot-SITL-212121?style=for-the-badge" height="25" />
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" height="25" />
</p>

<h1 align="center">Simulação ArduPilot com Gazebo Classic</h1>

<p align="center">
  Ambiente Docker para executar o ArduPilot SITL, Gazebo Classic, ROS 2 Humble e MAVROS com os modelos e mundos deste repositório.
</p>

---

## Requisitos

- Ubuntu com Docker Engine e o plugin Docker Compose (`docker compose`).
- Sessão gráfica com X11 ou XWayland disponível para abrir a interface do Gazebo.
- Para aceleração NVIDIA: placa compatível, driver instalado no host e NVIDIA Container Toolkit configurado no Docker.

O Compose padrão não exige GPU NVIDIA. A simulação também pode ser iniciada sem o override de GPU.

## Preparar o ambiente

Clone o repositório e entre na pasta:

```bash
git clone https://github.com/bernardo-sabino/avant-simulation.git
cd avant-simulation
```

### Configurar UID e GID

O container usa o mesmo UID/GID do usuário do host para que os arquivos criados no volume do projeto não fiquem pertencendo ao `root`.

Crie o arquivo local de configuração:

```bash
cp .env.example .env
id -u
id -g
```

Edite `.env` e coloque os valores retornados nos campos `USER_ID` e `GROUP_ID`. Por exemplo:

```dotenv
USER_ID=1000
GROUP_ID=1000
```

Os valores `1000:1000` funcionam em muitas instalações Ubuntu, mas use os valores mostrados no seu computador. O `.env` é local e não é enviado ao GitHub.

> Altere esses valores antes do primeiro build. Se mudar o UID/GID depois que a imagem já foi criada, reconstrua o container com `docker compose build --no-cache`.

## Iniciar sem NVIDIA

Use o Compose padrão em qualquer máquina Ubuntu, incluindo computadores sem placa NVIDIA:

```bash
docker compose up -d --build
docker compose exec ros_humble bash
```

O repositório é montado automaticamente em `/workspace`, independentemente do caminho onde foi clonado no host. Dentro do container, inicie um dos cenários:

```bash
cd /workspace/simulation
./start_grassworld.sh
```

Ou:

```bash
cd /workspace/simulation
./start_manometer_world.sh
```

## Iniciar com NVIDIA

Se o host tiver GPU NVIDIA e o NVIDIA Container Toolkit estiver instalado e configurado, combine os dois arquivos Compose:

```bash
docker compose -f docker-compose.yml -f docker-compose.nvidia.yml up -d --build
docker compose -f docker-compose.yml -f docker-compose.nvidia.yml exec ros_humble bash
```

Para verificar a configuração do Toolkit antes de iniciar o projeto:

```bash
docker run --rm --gpus all ubuntu nvidia-smi
```

Se esse comando falhar, corrija a instalação/configuração do driver NVIDIA ou do Container Toolkit no host. Em máquinas sem NVIDIA, não use `docker-compose.nvidia.yml`.

## Encerrar

Use os mesmos arquivos Compose escolhidos na inicialização. Para o modo padrão:

```bash
docker compose down
```

Para NVIDIA:

```bash
docker compose -f docker-compose.yml -f docker-compose.nvidia.yml down
```

