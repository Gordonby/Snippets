# Spring Apps - SQL Connection

Creating a spring connection for Azure Spring Apps to SQL Database with the az cli isn't as reliable as you'd like ([msft docs](https://learn.microsoft.com/en-us/azure/spring-apps/connect-managed-identity-to-azure-sql?tabs=service-connector)).

```output
az spring connection create sql --resource-group innerloop --service springy1 --app crufty1 --deployment connect-to-sql --target-resource-group innerloop --server sql-gobyers-indie-poc --database java1 --system-identity
Connection name is not specified, use generated one: --connection sql_g5kz3
Client type is not specified, use detected one: --client-type springBoot
Checking if Spring app enables System Identity...
Connecting to database...
Dependency pyodbc can't be installed, please install it manually with `/usr/bin/python3.9 -m pip install pyodbc`.
```

Even after installing pyodbc it seems to be a problem. 
It's likely that the problem isn't with pyodbc but connectivity with the sql database - but the error doesn't help.

![image](https://user-images.githubusercontent.com/17914476/206219426-9b465da5-f9b8-467c-af3c-8b572b1da450.png)

## Creating it manually.

Run this command to generate the right SQL statements to create the User

```bash
SPRINGAPPID=$(az spring app show -g innerloop -s springy1 -n crufty1 --query identity.principalId -o tsv)
SPRINGAPPNAME=$(az ad sp show --id $SPRINGAPPID --query displayName -o tsv)
echo "CREATE USER [$SPRINGAPPNAME] FROM EXTERNAL PROVIDER; 
ALTER ROLE db_datareader ADD MEMBER [$SPRINGAPPNAME];
ALTER ROLE db_datawriter ADD MEMBER [$SPRINGAPPNAME];
ALTER ROLE db_ddladmin ADD MEMBER [$SPRINGAPPNAME];
GO"
```

![image](https://user-images.githubusercontent.com/17914476/206220873-1b572220-8e07-44bf-9f2b-e254081e3966.png)

Use the SQL Query Editor to run the SQL Commands

![image](https://user-images.githubusercontent.com/17914476/206221069-1e70d20e-71ae-4045-8529-c080dde0ede0.png)

You can confirm the creation with this command

```tsql
SELECT name as username, create_date, 
       modify_date, type_desc as type
FROM sys.database_principals
WHERE type not in ('A', 'G', 'R', 'X')
      and sid is not null
      and name != 'guest'
```

![image](https://user-images.githubusercontent.com/17914476/206222014-b94964bd-02a9-459a-8a8b-61f712b4c912.png)
