# Snowflake Snowpark (python) - dbt

This project is trying to demonstrate the orchestrations of Snowpark python Stored procedures using dbt without the need of a Third Party Tool.

dbt is orchestrating the transformations including dbt models and snowpark stored procedures, this while keeping DAG lineage.

This project is made for UNIX based systems, it is possible to also run it on Windows but the specific requirements are not listed here.

## Requirements

* Snowflake account - [Snowflake signup](https://signup.snowflake.com/) 
* Require grants:
  * CREATE DATABASE
  * CREATE WAREHOUSE
  * CREATE SCHEMA
* Docker - [Docker community edition](https://hub.docker.com/search/?type=edition&offering=community)

## Installation
* 0.Clone this repo locally.
* 1.Login to your Snowflake account and create the following resources: database, warehouse, SP, etc.
  * Open the `sql/env-setup.sql` and add the password to the DBTDEMO user (at the end)
  * NOTE: If you get an error running the Stored Procedure saying you do not have Snowpark python enable, please activate and run again. Also add the password to the user (end of file) before running the script.
  * Run the scrip under `sql/env-setup.sql`.
* 2.Add Snowflake login to the file `.env`, you need to provide the following valid parameters after the equals sign:
  * ACCOUNT - (**WITHOUT** https:// AND snowflakecomputing.com/... **ONLY** account [locator](https://docs.snowflake.com/en/user-guide/admin-account-identifier.html)) 
  * DATABASE_USERNAME - Username
  * DATABASE_PASSWORD - Password
* 3.Start Docker - If you do not have installed then follow the link in Requirements section.
* 4.Open up a terminal and navigate to the location where you cloned this repository 
  * `cd ~/.../snowflake-dbt`
* 5.Once you are in the repository run the following command in your terminal: 
  * `make`
  * This will show the possible commands you can run. If you see and error after running it, make sure you added the variables under `.env` go to step 2.
* 6.Creating containers
  * `make setup` 
  * This will create the containers from where you will be running dbt. Installation of dbt is not required.
* 7.Running dbt
  * `make run` 
  * This will load the seeds, run dbt models (including snowpark), test the data, etc.
* 8.After you run it go to `http://localhost:8001/` to have a visual representation of your models.
* 9.Check the tables that dbt created in your Snowflake account.
* 10.If you are done and you required to clean your local containers, jump back to the terminal (go to the location where this project was cloned) and run:
  * `make clean`
  * This will remove all the containers, the container network, etc.

## dbt models
<img width="1705" alt="image" src="https://user-images.githubusercontent.com/107192982/193779535-ffe1d8f2-33a6-4da4-ad41-4765c0117aa2.png">

Once you have up and running the code head over to: `http://localhost:8001/#!/overview?g_v=1` the model called 
`stg_market_region_enhance` & `stg_top_imdb_score_movies` (highlighted in the picture above) are snowpark model being created and orchestrated using dbt.

## Usage

You can use this as a local demo, no dbt cloud is required.

## Snowflake-dbt

* Best Practices - [Document](https://drive.google.com/file/d/1A9SAv66y03eyA2JzC_ZfWccfEAS5Tspu/view)

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
