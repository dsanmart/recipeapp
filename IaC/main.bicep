// IaC for Web Apps
@sys.description('The FE Web App name.')
@minLength(3)
@maxLength(30)
param appServiceAppNameFe string = 'dsanmart-fe-app-bicep'
@sys.description('The BE Web App name.')
@minLength(3)
@maxLength(30)
param appServiceAppNameBe string = 'dsanmart-be-app-bicep'
@sys.description('The App Service Plan name.')
@minLength(3)
@maxLength(24)
param appServicePlanName string = 'dsanmart-app-bicep'
@sys.description('The environment type.')
@allowed([
  'nonprod'
  'prod'
  ])
param environmentType string = 'nonprod'
param location string = resourceGroup().location
var appServicePlanSkuName = 'B1'

@sys.description('The PostgreSQL server name.')
@minLength(3)
@maxLength(30)
param postgreServerName string = 'jseijas-dbsrv'
@sys.description('The PostgreSQL database name.')
@minLength(3)
@maxLength(30)
param dbname string = 'dsanmart-db'
@secure()
param dbhost string
@secure()
param dbuser string
@secure()
param dbpass string
@secure()
param dbport string
@secure()
param cookieSecret string

resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  kind: 'app,linux'
  properties: {
    reserved: true
  }
  sku: {
    name: appServicePlanSkuName
  }
}
resource appServiceAppFe 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppNameFe
  location: location
  properties: {
  serverFarmId: appServicePlan.id
  httpsOnly: true
  }
}

resource appServiceAppBe 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppNameBe
  location: location
  kind: 'app,linux'
  properties: {
    reserved: true
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'node|16-lts'
      appSettings: [
        {
          name: 'DATABASE_HOST'
          value: dbhost
        }
        {
          name: 'DATABASE_USER'
          value: dbuser
        }
        {
          name: 'DATABASE_PASSWORD'
          value: dbpass
        }
        {
          name: 'DATABASE_NAME'
          value: dbname
        }
        {
          name: 'DATABASE_PORT'
          value: dbport
        }
        {
          name: 'COOKIE_SECRET'
          value: cookieSecret
        }
      ]
    }
  }
}

// IaC for PostgreSQL
resource postgreServer 'Microsoft.DBforPostgreSQL/servers@2017-12-01' existing = {
  name: postgreServerName
}
resource serverDatabase 'Microsoft.DBforPostgreSQL/servers/databases@2017-12-01' = {
  name: dbname
  parent: postgreServer
}
