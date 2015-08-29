# encoding: utf-8
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.

require 'azure_resource_management'
require 'ms_rest_azure'

include MsRest
include MsRestAzure
include Azure::ARM::Resources

def create_resource_group(name: nil, location: nil)
  resource_group_name = name || get_random_name('RubySDKTest_')
  params = Models::ResourceGroup.new()
  params.location = location||'westus'

  RESOURCES_CLIENT.resource_groups.create_or_update(resource_group_name, params).value!.body
end

def delete_resource_group(name)
  RESOURCES_CLIENT.resource_groups.delete(name).value!
end

def get_random_name(prefix, length = 1000)
  prefix + SecureRandom.uuid.downcase.delete('^a-zA-Z0-9')[0...length - prefix.length]
end

tenant_id = ENV['azure_tenant_id']
client_id = ENV['azure_client_id']
secret = ENV['azure_client_secret']
subscription_id = ENV['azure_subscription_id']

token_provider = ApplicationTokenProvider.new(tenant_id, client_id, secret)
credentials = TokenCredentials.new(token_provider)

RESOURCES_CLIENT = ResourceManagementClient.new(credentials)
RESOURCES_CLIENT.subscription_id = subscription_id
