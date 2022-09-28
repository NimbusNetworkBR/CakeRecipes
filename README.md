# CakeRecipes
* Scripts gerais


## Dehydrated - Instalador
### Instalar o Dehydrated
```
curl -s https://raw.githubusercontent.com/NimbusNetworkBR/CakeRecipes/prod/acme-ubuntu.sh | bash
```

### Os dominios são adicionados aqui, um por linha. Se ele houver mais de um hostname, só adicionar separado por espaço.
```
/etc/dehydrated/domains.txt
```
* Se não havia um domains.txt, ele contém um exemplo com todas as possibilidades e devem ser excluidas ou comentádas.
* Precisa adicionar esse include no nginx, em todos os virtual hosts.
* Pra evitar problemas com a renovação, o redirect pra https:// precisa estar dentro do "location / {}"
```
include snippets/acme.conf;
```

* Caso precise validar o certificado por DNS (no caso de usar um certificado wildcard, por exemplo),