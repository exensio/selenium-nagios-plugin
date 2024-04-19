# selenium-nagios-plugin
A simple Nagios Plugin which starts a Selenium Script.
It may help to monitor web applications which do not provide an API.

## [exensio GmbH Blog](https://www.exensio.de/news-medien)

This repositroy is created for the blogpost: [Nagios Monitoring von Webanwendungen mit Selenium](https://www.exensio.de/news-medien/newsreader-blog/nagios-monitoring-von-webanwendungen-mit-selenium)

## Requirements
The plugin relies on [Selenium Grid](https://github.com/SeleniumHQ/selenium/wiki/Grid2) and [SeInterpreter](https://github.com/SeleniumBuilder/se-builder/wiki/Se-Interpreter).
It expects a Selenium Grid hub which can run on a remote host or on localhost. Furthermore, it requires Java RE installed and the JAR file of SeInterpreter available on localhost.

## Installation
The installation and configuration of the plugin is very simple.

1. Download, unzip and copy the script `check_website_by_selenium.sh` to your Nagios plugin location (see USER2 in the Nagios documentation)
2. Adapt the path to both, JRE and SeInterpreter according to your needs, see section *Default options* in the script

The Plugin can be used with Nagios/Thruk/Icinga.

## Command Line Usage
```
./check_website_by_selenium.sh -s demo.json
```

## Nagios Plugin Configuration
My *commands.cfg* looks like this:
```
define command {
  command_name                   check_website_by_selenium
  command_line                   $USER2$/check_website_by_selenium.sh -s $ARG1$ -h $ARG2$ -b $ARG3$ -v $ARG4$
}
```

And my *services.cfg* looks like this:
```
define service {
  service_description            check_website_by_selenium_demo
  host_name                      demo_host
  use                            check_mk_active
  check_command                  check_website_by_selenium!/tmp/demo.json
}
```
