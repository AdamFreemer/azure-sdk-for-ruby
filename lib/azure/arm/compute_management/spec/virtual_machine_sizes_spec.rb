# encoding: utf-8
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.

require_relative 'test_helper'
require_relative 'availability_sets_shared'

include MsRestAzure
include Azure::ARM::Compute

describe VirtualMachineSizes do
  before(:all) do
    @location = 'westus'
    @client = COMPUTE_CLIENT.virtual_machine_sizes
  end

  it 'should list available virtual machine sizes' do
    result = @client.list(@location).value!
    expect(result.response.status).to eq(200)
    expect(result.body).not_to be_nil
    expect(result.body.value).to be_a Array
  end
end