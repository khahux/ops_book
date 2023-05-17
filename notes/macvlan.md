# macvlan模式，宿主机和容器互通

## 路由

```shell
# macvlan0
docker network create -d macvlan --subnet=10.123.1.0/24 --gateway=10.123.1.2 -o parent=ens33 macvlan0

# macvlan0-host,加入 /etc/rc.d/rc.local
ip link add macvlan0-host link ens33 type macvlan mode bridge
ip addr add 10.123.1.200 dev macvlan0-host
ip link set macvlan0-host up

# 修改路由，让宿主机到容器(10.123.1.101)的数据经过macvlan0-host
ip route add 10.123.1.101 dev macvlan0-host
```

## 容器

```yaml
version: '3'
services:
  nginx:
    image: nginx:1.22.1-alpine
    container_name: nginx
    restart: always
    environment:
      TZ: Asia/Shanghai
    networks:
      macvlan0:
        ipv4_address: 10.123.1.101
    volumes:
      - /etc/timezone:/etc/timezone
      - ...

networks:
  macvlan0:
    external: true
```


## 参考

- https://smalloutcome.com/2021/07/18/Docker-%E4%BD%BF%E7%94%A8-macvlan-%E7%BD%91%E7%BB%9C%E5%AE%B9%E5%99%A8%E4%B8%8E%E5%AE%BF%E4%B8%BB%E6%9C%BA%E7%9A%84%E9%80%9A%E4%BF%A1%E8%BF%87%E7%A8%8B/
- https://rehtt.com/index.php/archives/236/