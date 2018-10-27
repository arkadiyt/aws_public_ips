### 1.0.6 (10/26/2018)
* Ignore services when they're not available in the requested region
* Update dependencies

### 1.0.5 (05/25/2018)
* Output more details in text formatter when using --verbose

### 1.0.4 (05/20/2018)
* Handle RDS and Redshift instances which are in the process of coming up/down
* Add --help, --version commands to CLI
* Improve CLI error output
* Fix issue where using the EC2 check with the JSON formatter could output empty entries
* Fix issue with RDS check where the endpoint hostname was not being counted as a public IP

### 1.0.3 (05/17/2018)
* Fix bug in relative file loading/checking

### 1.0.2 (05/15/2018)
* Don't depend on bundler being installed

### 1.0.1 (05/15/2018)
* Fix a bug where the gem was not installing an executable CLI script

### 1.0.0 (05/13/2018)
* Initial release
