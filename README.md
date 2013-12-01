# About this project

Vagrant Setup + Chef Cookbook + Maven Build Example for JBoss for Remote Deployment

## Chef Recipe

  * Create a password, assign the resulting line to json blob e.g.:

```
{ 
  "jboss": {
    "bind" {
      "management": "0.0.0.0", # Where to bind mgmt interface
      "public": "0.0.0.0", # Where to bind public interface
      "unsecure": "0.0.0.0" # Where to bind unsecure interface
    },
    "jboss_admins": "admin=yourlongpassword"
  }
}
```

For more details on this format, see bin/add-user.sh in jboss

## Changes from Stock jboss cookbook:

We mix the best parts from [chef-jbossas7](https://github.com/wharton/chef-jbossas7) (which is RHEL-supported only) with the stock chef-jboss cookbook. Mainly:

  * Uses upstart instead of /etc/init.d
  * Caches the jboss file
  * Allows fine tuning of container startup options (standalone.erb), allowing for binding

## Bootstrapping

  * Install Vagrant (from .deb from vagrantup.com), Virtualbox (Same, but virtualbox.org), and [RVM](http://rvm.io)
    * Then, ```vagrant plugin install vagrant-berkshelf && vagrant plugin install vagrant-omnibus```
  * From rvm, issue:
    * ```gem install foodcritic berkshelf bundler --no-ri --no-rdoc```

... and then on ```jboss-vagrant directory```

  * when beginning: ```vagrant up```
  * when finished: ```vagrant halt```
  * when modified (Vagrantfile): ```vagrant reload```
  * when modified (chef): ```vagrant provision```
  * when done (vagrant): ```vagrant destroy -y```

## Relevant settings.xml sections:

```
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      http://maven.apache.org/xsd/settings-1.0.0.xsd">
	<servers>
		<server>
			<id>jboss-build-server</id>
			<username>admin</username>
			<password>password</password>
		</server>
	</servers>
	<profiles>
		<profile>
			<id>default</id>
			<properties>
				<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
				<gpg.passphrase/>
				<jboss-as.id>jboss-build-server</jboss-as.id>
				<jboss-as.hostname>localhost</jboss-as.hostname>
			</properties>
			// ...
		</profile>
	</profiles>
	<activeProfiles>
		<activeProfile>default</activeProfile>
	</activeProfiles>
</settings>

```

## pom.xml surgery

Simply declare Maven Plugin. Version 7.5.Final is recommended:

```
<plugin>
	<groupId>org.jboss.as.plugins</groupId>
	<artifactId>jboss-as-maven-plugin</artifactId>
	<version>7.5.Final</version>
</plugin>
```

## TODO

  * Allow master/slave setups a-la chef-jbossas7
