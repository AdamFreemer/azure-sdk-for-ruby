# encoding: utf-8
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.

require_relative 'spec_helper'

include MsRestAzure
include Azure::ARM::Storage

describe StorageManagementClient do
  before(:all) do
    @client = STORAGE_CLIENT.usage_operations
  end

  it 'list usage operations' do
    result = @client.list.value!
    expect(result.body.value).not_to be_nil
    expect(result.body.value).to be_a(Array)
  end

end
