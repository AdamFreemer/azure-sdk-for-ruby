# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.

require_relative 'test_helper'

include MsRestAzure
include Azure::ARM::Compute

describe UsageOperations do
  before(:all) do
    @client = COMPUTE_CLIENT.usage_operations
  end

  it 'should list usages' do
    result = @client.list('westus').value!
    expect(result.response.status).to eq(200)
    expect(result.body).not_to be_nil
    expect(result.body.value).to be_a Array
  end
end