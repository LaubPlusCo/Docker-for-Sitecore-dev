# Mongo on Docker for Sitecore development

This extremely simple docker compose file starts a container running MongoDB 3.2. It is ideal when running local Sitecore development instances that requires a MongoDB.

## Prerequisites
- Docker v17.06.0  or later - [Download here](https://store.docker.com/editions/community/docker-ce-desktop-windows)
- Docker has to be set for Linux containers   

## Usage (first time)

1. Open Powershell or other command line as admin in ./containers/mongo/3.2/
2. Run > $ docker-compose up
3. Wait for container to start

## Configuration

#### Multiple development instances

To support multiple development instances on the same machine you can use a dedicated MongoDB instance for each.
  
  *Note*: it is not required to have multiple MongoDBs to support multiple Sitecore development instances as long as you ensure the collection names in connectionstrings.config are unique *Convention: {instance_name}_{collection name}*

1. Make a copy of the folder /containers/solr/bitnami-6.6-sitecore and name it according to the development instance
2. Rename the container by editing the docker-compose.yml file and change localhost port
```yaml
version: "3.3"
services:
  {new name}:
    image: mongo:3.2
    container_name: "mongodb-3.2"
    environment:
      - MONGO_DATA_DIR=/data/db
      - MONGO_LOG_DIR=/dev/null
    volumes:
      - data:/data/db
    ports:
      - {localhost port}:27017
    command: mongod --smallfiles --logpath=/dev/null --quiet
    logging:
      driver: "json-file"
      options:
        max-size: "200k"
        max-file: "10"
volumes:
  data: 
```
3. Run > $ docker-compose up
4. Edit /App_Config/connectionstrings.config 

``` xml
<?xml version="1.0" encoding="utf-8"?>
<connectionStrings>
...
  <add name="analytics" connectionString="mongodb://localhost:{localhost port}/{instance_name}_analytics" />
  <add name="tracking.live" connectionString="mongodb://localhost:{localhost port}/{instance_name}_tracking_live" />
  <add name="tracking.history" connectionString="mongodb://localhost:{localhost port}/{instance_name}_tracking_history" />
  <add name="tracking.contact" connectionString="mongodb://localhost:{localhost port}/{instance_name}_tracking_contact" />
</connectionStrings>
```
_Suggested convention;_ 

Copy the folder to your solution version control repo ex. ~/containers/mongodb/  
*Remember to Add the {folder}/data/db dir to your VC ignore file (.gitignore/.tfignore)

**Anders Laub @Laub+Co**  
*Feedback and comments welcome [contact me](mailto:contact@laubplusco.net)*