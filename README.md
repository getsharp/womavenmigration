# WOnder Maven Migrator

A Bash script that attempts to convert a WebObjects/WOnder Fluffy Bunny project to a Maven project based on https://gist.github.com/hugith/e9a49e91fbcebe204e0feb4989f55631 (https://github.com/hugith) and https://gist.github.com/paulhoadley/cd15b90c94eb8c640fddd9ac3fbbc6dc (https://github.com/paulhoadley)

### Overview

* Adds a .project file with derived project name
* Adds a pom.xml file with derived or user provided groupId, artifactId and WOnder version
* Replaces the .classpath file
* Replaces woproject directory
* Updates classes.dir in build.properties
* Creates maven project structure and moves appropriate content
* Updates path references in .eogen files

### Usage

```
$ git clone https://github.com/getsharp/womavenmigration.git
$ cd womavenmigration
$ ./migrate.sh /path/to/WOnder/project
```

### Example Output

```
$ ./migrate.sh ../myframework/

WOnder Maven Migrator

Converts a WOnder fluffy bunny project to a WOnder Maven project.
Configuring dependecies beyond stock WOnder frameworks in pom.xml is required.

This process is destructive and assumes you have backed up your target project.

Do you wish to continue (y/n)? y

Let's get cracking

Project Name: MyFramework
Project Type: framework

pom.xml groupId [com.airconhum.core]: 
com.airconhum.core

pom.xml artifactId [MyFramework]: 
MyFramework

pom.xml Wonder version [7.1-SNAPSHOT]: 
7.1-SNAPSHOT

Adding a .project file
Replacing project name placeholder with MyFramework

Changing build.properties classes.dir value to target/classes

Backing up and replacing the .classpath file.

Replacing woproject directory to introduce the appropriate .patternset files

Adding a pom.xml file
Replacing groupId placeholder with com.airconhum.core
Replacing artifactId placeholder with MyFramework
Replacing project name placeholder with MyFramework
Replacing wonder.version placeholder with 7.1-SNAPSHOT
Removing <packaging>woapplication</packaging> from pom.xml

Creating a standard Maven project structure
Moving Sources to src/main/java
Moving Resources to src/main/resources
Finding .eogen files in src/main/resources and changing path references to new structure
Updating src/main/resources/Provisioning/Model1.eogen
Updating src/main/resources/Provisioning/Model2.eogen

Done.

Use .classpath.old help configure pom.xml dependencies

$ 

```
