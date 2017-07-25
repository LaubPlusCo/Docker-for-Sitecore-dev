# SOLR on Docker for Sitecore development

This simple docker compose file starts a container running Bitnami SOLR 6.6.0 with cores defined for a standard Sitecore installation. SOLR core definitions for Sitecore is shared with the container so no additional setup is required.

You can have a local SOLR instance running and configured for Sitecore 8.2.x in less than a minute making this extremely efficient for local Sitecore development instances.

## Prerequisites
- Docker v17.06.0  or later - [Download here](https://store.docker.com/editions/community/docker-ce-desktop-windows)

## Usage

1. Open Powershell as admin in /containers/solr/bitnami-6.6-sitecore/
2. Run > $ docker-compose up
3. Wait for SOLR to start
4. Verify installation on localhost:8983

    That's it. If the bitnami is cached on your machine it takes even less than a minute.

**More steps for first time run**

5. Configure Sitecore to use SOLR 

    See f. ex [Setting up SOLR in Habitat](https://www.sitecorenutsbolts.net/2016/06/28/Setting-up-Solr-on-Habitat/) for an automated approach

6. Rebuild all search indexes in Sitecore from the Control Panel

## Configuration

#### Multiple development instances

To support multiple development instances on the same machine you should use a dedicated SOLR instance for each.

1. Make a copy of the folder /containers/solr/bitnami-6.6-sitecore and name it according to the development instance
2. Rename the container by editing the docker-compose.yml and change the localhost port
```yaml
version: "3.3"
services:
  {new name}:
    image: bitnami/solr:6.6.0-r1
    ports:
      - {localhost port}:8983
    volumes:
      - ./data:/bitnami    
    logging:
      driver: "json-file"
      options:
        max-size: "200k"
        max-file: "10"
    tty: true    
```
3. Go to folder in Powershell or other cmd line and run > $ docker-compose up
4. Change the Sitecore configuration setting *ContentSearch.Solr.ServiceBaseAddress* to http://localhost:{localhost port} - Remember; always use a patch file to change Sitecore config settings. 

_Suggested convention;_ 

Copy the folder to your solutions version control repo ex. ~/containers/solr/  
*Remember to Add the {folder}/data/indexes dir to your ignore file (.gitignore/.tfignore)*

###  Other Sitecore versions  

The schema.xml file and SOLR cores matches an ootb Sitecore 8.2.1 instance but can easily be used for other (old and newer) versions of Sitecore. 

1. Run the container > $ docker-compose up
2. This will create a configsets folder under ./data/solr/data
3. Stop the container again > $ docker-compose down
3. Follow instructions [2] in the Sitecore docs [found here](https://kb.sitecore.net/articles/227897) to generate a new schema.xml
4. Replace schema.xml files in the folders with Sitecore index names under ./data/solr/data
5. Delete the folders with index names that are not used in the version of Sitecore (if any)
6. If other indexes needed copy-paste an index folder, rename it, and edit the core.properties file in the copied folder to match the index name

*__Note__*: Several known bugs in the generated schema.xml file exists for various versions of Sitecore. Using the files that exists in this repo should work for older versions and fix these bugs. It has currently not been tested though.

#### Adding new SOLR cores

1. Stop the SOLR container if it is running ($ docker-compose stop)
2. Copy-paste one of the existing SOLR core folders under ./data/solr/data
3. Rename the folder to the name of your new core
4. Edit /{name of new core}/core.properties
```yaml
name={name of new core}
config=solrconfig.xml
schema=schema.xml
dataDir=/bitnami/data/{name of nnew core}
```
5. If the core require other fields to be added to the SOLR schema.xml then edit /{name of your core}/conf/schema.xml accordingly
6. Start the SOLR container again ($ docker-compose start)

*__Note__*: SOLR 6.6 is NOT OFFICIALLY SUPPORTED by Sitecore - see [Sitecore SOLR Compatibility table](https://kb.sitecore.net/articles/227897) . However it does work fine for development.

### Please Contribute
Report bugs, make fixes, add other versions etc.

Anders Laub  
[Contact](mailto:contact@laubplusco.net)  @Laub+Co
