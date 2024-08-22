### Running 

Commands used to run Minecraft bedrock dedicated server locally on my ubuntu server.

```bash
sudo docker run -d -v ~/Minecraft:/data -p 19132:19132/udp -e EULA=TRUE -e VERSION=1.20.61.01 -e GAMEMODE'='survival -e LEVEL_NAME=byers-ultimate-world -e LEVEL_SEED=8486214866965744170 -e TICK_DISTANCE=4 -e DIFFICULTY=hard itzg/minecraft-bedrock-server:2023.8.1
```

```bash
sudo docker run -d -v ~/Minecraft:/data -p 19132:19132/udp -e EULA=TRUE -e VERSION=1.21.20.03 -e GAMEMODE'='survival -e LEVEL_NAME=byers-ultimate-world -e LEVEL_SEED=8486214866965744170 -e TICK_DISTANCE=4 -e DIFFICULTY=hard itzg/minecraft-bedrock-server:2024.5.0
```
### Logging

```bash
sudo docker logs $(sudo docker ps --quiet | awk '{print $1}')
```
