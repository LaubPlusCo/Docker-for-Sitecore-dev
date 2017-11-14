# SOLR on Docker for Sitecore development

This simple docker compose file starts a container running Bitnami SOLR 6.6.1 with cores defined for a standard Sitecore installation. SOLR core definitions for Sitecore is shared with the container so no additional setup is required.

You can have a local SOLR instance running and configured for Sitecore 9.0 in less than a minute making this extremely efficient for local Sitecore development instances.

This uses a slightly modified version of Kamsar's solrssl.ps1: 
https://gist.github.com/kamsar/c3c8322c1ec40eac64c7dd546e5124de

This also uses modified versions of ivansharamok flexible SOLR containers for Sitecore:
https://github.com/ivansharamok/Content/blob/master/articles/flexible-solr-container-image-for-sitecore.md

## Prerequisites
- Docker v17.06.0  or later - [Download here](https://store.docker.com/editions/community/docker-ce-desktop-windows)

## Usage

1. Open Powershell as admin in /containers/solr/6.6.1-bitnami-sitecore-ssl/
2. Run > $ .\solrssl.ps1
3. Run > $ docker-compose up
4. Wait for SOLR to start
5. Verify installation on localhost:8983

    That's it. If the bitnami is cached on your machine it takes even less than a minute.

**More steps for first time run**

6. Configure Sitecore to use SOLR 

    See f. ex [Setting up SOLR in Habitat](https://www.sitecorenutsbolts.net/2016/06/28/Setting-up-Solr-on-Habitat/) for an automated approach

7. Rebuild all search indexes in Sitecore from the Control Panel

## Configuration

#### Multiple development instances

To support multiple development instances on the same machine you should use a dedicated SOLR instance for each.

1. Make a copy of the folder /containers/solr/6.6.1-bitnami-sitecore-ssl and name it according to the development instance
2. Rename the container by editing the docker-compose.yml and change the localhost port
```yaml
version: "3.3"
services:
  {new name}:
    image: bitnami/solr:6.6.1-r0
    ports:
      - {localhost port}:8983
    volumes:
      - ./data:/bitnami    
    logging:
      driver: "json-file"
      options:
        max-size: "200k"
        max-file: "10"
    environment:
      SOLR_SSL_KEY_STORE: /bitnami/solr-ssl.keystore.jks
      SOLR_SSL_KEY_STORE_PASSWORD: secret
      SOLR_SSL_TRUST_STORE: /bitnami/solr-ssl.keystore.jks
      SOLR_SSL_TRUST_STORE_PASSWORD: secret
    tty: true        
```
3. Run > $ .\solrssl.ps1 (or copy the solr-ssl.keystore.jks file)
4. Go to folder in Powershell or other cmd line and run > $ docker-compose up
5. Change the Sitecore configuration setting *ContentSearch.Solr.ServiceBaseAddress* to http://localhost:{localhost port} - Remember; always use a patch file to change Sitecore config settings. 

_Suggested convention;_ 

Copy the folder to your solutions version control repo ex. ~/containers/solr/  
*Remember to Add the {folder}/data/indexes dir to your ignore file (.gitignore/.tfignore)*

### Please Contribute
Report bugs, make fixes, add other versions etc.