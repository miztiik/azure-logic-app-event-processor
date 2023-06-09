// SET MODULE DATE
param module_metadata object = {
  module_last_updated : '2023-05-19'
  owner: 'miztiik@github'
}

param deploymentParams object
param tags object
param osKind string

param storeEventsRuleName string
param storeEventsLogFilePattern string
param storeEventscustomTableNamePrefix string

param automationEventsRuleName string
param automationEventsLogFilePattern string
param automationEventsCustomTableNamePrefix string

param managedRunCmdRuleName string 
param managedRunCmdLogFilePattern string
param managedRunCmdCustomTableNamePrefix string

param linDataCollectionEndpointId string
param logAnalyticsPayGWorkspaceId string
param logAnalyticsPayGWorkspaceName string

resource r_storeEvents_dcr 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  name: '${storeEventsRuleName}_${deploymentParams.loc_short_code}_${deploymentParams.global_uniqueness}'
  location: deploymentParams.location
  tags: tags
  kind: osKind
  properties: {
    description: 'Log collection rule for miztiik web store data across all linux Vms.'
    dataCollectionEndpointId: linDataCollectionEndpointId
    streamDeclarations: {
      'Custom-${storeEventscustomTableNamePrefix}_CL': {
        columns: [
          {
            name: 'TimeGenerated'
            type: 'datetime'
          }
          {
            name: 'RawData'
            type: 'string'
          }
          {
            name: 'request_id'
            type: 'string'
          }
          {
            name: 'event_type'
            type: 'string'
          }
          {
            name: 'store_id'
            type: 'int'
          }
          {
            name: 'cust_id'
            type: 'int'
          }
          {
            name: 'category'
            type: 'string'
          }
          {
            name: 'sku'
            type: 'int'
          }
          {
            name: 'price'
            type: 'real'
          }
          {
            name: 'qty'
            type: 'int'
          }
          {
            name: 'discount'
            type: 'real'
          }
          {
            name: 'gift_wrap'
            type: 'boolean'
          }
          {
            name: 'variant'
            type: 'string'
          }
          {
            name: 'priority_shipping'
            type: 'boolean'
          }
          {
            name: 'contact_me'
            type: 'string'
          }
        ]
      }
    }
    dataSources: {
      logFiles: [
        {
          streams: [
            'Custom-${storeEventscustomTableNamePrefix}_CL'
          ]
          filePatterns: [
            storeEventsLogFilePattern
          ]
          format: 'text'
          settings: {
            text: {
              recordStartTimestampFormat: 'ISO 8601'
            }
          }
          // name: '${storeEventscustomTableNamePrefix}_CL'
          name: 'myFancyLogFileFormat'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: logAnalyticsPayGWorkspaceName
          workspaceResourceId: logAnalyticsPayGWorkspaceId
        }
      ]
    }
    dataFlows: [
      {
        streams: [ 'Custom-${storeEventscustomTableNamePrefix}_CL' ]
        destinations: [ logAnalyticsPayGWorkspaceName ]
        transformKql: 'source | extend jsonContext = parse_json(tostring(RawData)) | extend TimeGenerated=now(), RawData=tostring(RawData), request_id=tostring(jsonContext.request_id) , event_type=tostring(jsonContext.event_type), store_id=toint(jsonContext.store_id),cust_id=toint(jsonContext.cust_id),category=tostring(jsonContext.category),sku=toint(jsonContext.sku),price=toreal(jsonContext.price),qty=toint(jsonContext.qty),discount=toreal(jsonContext.discount),gift_wrap=tobool(jsonContext.gift_wrap),variant=tostring(jsonContext.variant),priority_shipping=tobool(jsonContext.priority_shipping),contact_me=tostring(jsonContext.contact_me)'
        outputStream: 'Custom-${storeEventscustomTableNamePrefix}_CL'
      }
    ]
  }
}


// Rule for Automation Logs
resource r_automationEvents_dcr 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  name: '${automationEventsRuleName}_${deploymentParams.loc_short_code}_${deploymentParams.global_uniqueness}'
  location: deploymentParams.location
  tags: tags
  kind: osKind
  properties: {
    description: 'Log collection rule for miztiik automation events across all linux Vms.'
    dataCollectionEndpointId: linDataCollectionEndpointId
    streamDeclarations: {
      'Custom-${automationEventsCustomTableNamePrefix}_CL': {
        columns: [
          {
            name: 'TimeGenerated'
            type: 'datetime'
          }
          {
            name: 'RawData'
            type: 'string'
          }
          {
            name: 'request_id'
            type: 'string'
          }
        ]
      }
    }
    dataSources: {
      logFiles: [
        {
          streams: [
            'Custom-${automationEventsCustomTableNamePrefix}_CL'
          ]
          filePatterns: [
            automationEventsLogFilePattern
          ]
          format: 'text'
          settings: {
            text: {
              recordStartTimestampFormat: 'ISO 8601'
            }
          }
          // name: '${storeEventscustomTableNamePrefix}_CL'
          name: 'myFancyLogFileFormat'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: logAnalyticsPayGWorkspaceName
          workspaceResourceId: logAnalyticsPayGWorkspaceId
        }
      ]
    }
    dataFlows: [
      {
        streams: [ 'Custom-${automationEventsCustomTableNamePrefix}_CL' ]
        destinations: [ logAnalyticsPayGWorkspaceName ]
        transformKql: 'source | extend TimeGenerated=now(), RawData=tostring(RawData)'
        outputStream: 'Custom-${automationEventsCustomTableNamePrefix}_CL'
      }
    ]
  }
}

// /var/log/azure/run-command/handler.log
// https://learn.microsoft.com/en-us/azure/virtual-machines/linux/run-command

// Rule for Managed Run Command Logs
resource r_managed_run_cmd_dcr 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  name: '${managedRunCmdRuleName}_${deploymentParams.loc_short_code}_${deploymentParams.global_uniqueness}'
  location: deploymentParams.location
  tags: tags
  kind: osKind
  properties: {
    description: 'Log collection rule Managed Run Command executions across all linux Vms. https://learn.microsoft.com/en-us/azure/virtual-machines/linux/run-command#action-run-command-linux-troubleshooting'
    dataCollectionEndpointId: linDataCollectionEndpointId
    streamDeclarations: {
      'Custom-${managedRunCmdCustomTableNamePrefix}_CL': {
        columns: [
          {
            name: 'TimeGenerated'
            type: 'datetime'
          }
          {
            name: 'RawData'
            type: 'string'
          }
        ]
      }
    }
    dataSources: {
      logFiles: [
        {
          streams: [
            'Custom-${managedRunCmdCustomTableNamePrefix}_CL'
          ]
          filePatterns: [
            managedRunCmdLogFilePattern
          ]
          format: 'text'
          settings: {
            text: {
              recordStartTimestampFormat: 'ISO 8601'
            }
          }
          // name: '${storeEventscustomTableNamePrefix}_CL'
          name: 'myFancyLogFileFormat'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: logAnalyticsPayGWorkspaceName
          workspaceResourceId: logAnalyticsPayGWorkspaceId
        }
      ]
    }
    dataFlows: [
      {
        streams: [ 'Custom-${managedRunCmdCustomTableNamePrefix}_CL' ]
        destinations: [ logAnalyticsPayGWorkspaceName ]
        transformKql: 'source | extend TimeGenerated=now(), RawData=tostring(RawData)'
        outputStream: 'Custom-${managedRunCmdCustomTableNamePrefix}_CL'
      }
    ]
  }
}

// OUTPUTS
output module_metadata object = module_metadata

output storeEventsDcrId string = r_storeEvents_dcr.id
output automationEventsDcrId string = r_automationEvents_dcr.id
