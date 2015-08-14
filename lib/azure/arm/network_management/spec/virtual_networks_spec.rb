# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.

require_relative 'test_helper'
require_relative 'network_shared'

include MsRestAzure
include Azure::ARM::Resources
include Azure::ARM::Network

describe VirtualNetworks do

  before(:all) do
    @client = NETWORK_CLIENT.virtual_networks
    @resource_group = create_resource_group
    @location = 'westus'
  end

  after(:all) do
    delete_resource_group(@resource_group.name)
  end


  it 'should create virtual network' do
    virtualNetworkName = get_random_name("vnet")
    params = build_virtual_network_params(@location)
    result = @client.create_or_update(@resource_group.name, virtualNetworkName, params).value!

    expect(result.response.status).to eq(200)
    expect(result.body).not_to be_nil
    expect(result.body.location).to eq(params.location)
    expect(result.body.name).to eq(virtualNetworkName)
  end

  it 'should get virtual network' do
    vnet = create_virtual_network(@resource_group.name)
    result = @client.get(@resource_group.name, vnet.name).value!
    expect(result.response.status).to eq(200)
    expect(result.body).not_to be_nil
    expect(result.body.name).to eq(vnet.name)
  end

  it 'should list all virtual networks' do
    result = @client.list_all.value!
    expect(result.body.value).not_to be_nil
    expect(result.body.value).to be_a(Array)

    until result.body.next_link.to_s.empty? do
      result = @client.list_next(result.body.next_link).value!
      expect(result.body.value).not_to be_nil
      expect(result.body.value).to be_a(Array)
    end
  end

  it 'should list all virtual networks in resource group' do
    result = @client.list(@resource_group.name).value!
    expect(result.body.value).not_to be_nil
    expect(result.body.value).to be_a(Array)

    until result.body.next_link.to_s.empty? do
      result = @client.list_next(result.body.next_link).value!
      expect(result.body.value).not_to be_nil
      expect(result.body.value).to be_a(Array)
    end
    end

  it 'should list all Virtual Networks in a subscription' do
    result = @client.list_all.value!
    expect(result.response.status).to eq(200)
    expect(result.body).not_to be_nil
    expect(result.body.value).to be_a(Array)
    until result.body.next_link.to_s.empty? do
      result = @client.list_all_next(result.body.next_link).value!
      expect(result.body.value).not_to be_nil
      expect(result.body.value).to be_a(Array)
    end
  end

  it 'should delete virtual network' do
    vnet = create_virtual_network @resource_group.name
    result = @client.delete(@resource_group.name, vnet.name).value!
    expect(result.response.status).to eq(200)
  end

end