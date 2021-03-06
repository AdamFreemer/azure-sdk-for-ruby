#-------------------------------------------------------------------------
# # Copyright (c) Microsoft and contributors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------
require "integration/test_helper"

describe Azure::ServiceBus::ServiceBusService do
  subject { Azure::ServiceBus::ServiceBusService.new }
  let(:topic){ 'test-topic' }
  let(:subscription){ "mySubscription" }
  let(:rule){ "myRule" }

  describe "Service bus rules" do
    before do
      VCR.insert_cassette "service_bus/#{name}"
      subject.create_topic topic
      subject.create_subscription topic, subscription
    end

    after do
      subject.delete_topic topic
      VCR.eject_cassette
    end

    it "should create a new rule" do
      result = subject.create_rule topic, subscription, rule

      result.must_be :kind_of?, Azure::ServiceBus::Rule
      result.filter.must_be_kind_of Azure::ServiceBus::TrueFilter
      result.filter.sql_expression.must_equal "1=1"
      result.filter.compatibility_level.must_equal 20
    end

    it "should create a new rule from rule object" do
      ruleObject = Azure::ServiceBus::Rule.new "my_other_rule"
      ruleObject.subscription = subscription
      ruleObject.topic = topic

      result = subject.create_rule ruleObject
      result.must_be :kind_of?, Azure::ServiceBus::Rule
      result.filter.must_be_kind_of Azure::ServiceBus::TrueFilter
      result.filter.sql_expression.must_equal "1=1"
      result.filter.compatibility_level.must_equal 20
    end

    it "should create a new rule with an action" do
      ruleObject = Azure::ServiceBus::Rule.new "my_other_rule"
      ruleObject.subscription = subscription
      ruleObject.topic = topic
      ruleObject.filter = Azure::ServiceBus::SqlFilter.new({ :sql_expression => "MyProperty='XYZ'" })
      ruleObject.action = Azure::ServiceBus::SqlRuleAction.new({ :sql_expression => "set MyProperty2 = 'ABC'" })

      result = subject.create_rule ruleObject
      result.must_be :kind_of?, Azure::ServiceBus::Rule
      result.filter.must_be_kind_of Azure::ServiceBus::SqlFilter
      result.filter.sql_expression.must_equal "MyProperty='XYZ'"
      result.filter.compatibility_level.must_equal 20

      result.action.must_be_kind_of Azure::ServiceBus::SqlRuleAction
      result.action.sql_expression.must_equal "set MyProperty2 = 'ABC'"
      result.action.compatibility_level.must_equal 20
    end

    it "should create a new rule with a correlation filter" do
      ruleObject = Azure::ServiceBus::Rule.new "my_other_rule"
      ruleObject.subscription = subscription
      ruleObject.topic = topic
      ruleObject.filter = Azure::ServiceBus::CorrelationFilter.new({ :correlation_id => "identifier" })
      ruleObject.action = Azure::ServiceBus::SqlRuleAction.new({ :sql_expression => "set MyProperty2 = 'ABC'" })

      result = subject.create_rule ruleObject
      result.must_be :kind_of?, Azure::ServiceBus::Rule
      result.filter.must_be_kind_of Azure::ServiceBus::CorrelationFilter
      result.filter.correlation_id.must_equal "identifier"

      result.action.must_be_kind_of Azure::ServiceBus::SqlRuleAction
      result.action.sql_expression.must_equal "set MyProperty2 = 'ABC'"
      result.action.compatibility_level.must_equal 20
    end
  end

  describe "when a rule exists" do
    before do
      VCR.insert_cassette "service_bus/#{name}"
      subject.create_topic topic
      subject.create_subscription topic, subscription
      subject.create_rule topic, subscription, rule
    end

    after do
      subject.delete_topic topic
      VCR.eject_cassette
    end

    it "should be able to get rules" do
      result = subject.get_rule topic, subscription, rule
      result.must_be :kind_of?, Azure::ServiceBus::Rule
      result.filter.must_be_kind_of Azure::ServiceBus::TrueFilter
      result.filter.sql_expression.must_equal "1=1"
      result.filter.compatibility_level.must_equal 20
    end

    it "should be able to list rules" do
      result = subject.list_rules topic, subscription
      rule_found = false
      result.each do |r|
        rule_found = true if r.name == rule
      end
      assert rule_found, "list_rules didn't include the expected rule"
    end

    it "should be able to delete rules" do
      subject.delete_rule topic, subscription, rule
    end
  end

  describe 'when multiple rules exist' do
    let(:rule1) { "myRule1" }
    let(:rule2) { "myRule2" }

    before do
      VCR.insert_cassette "service_bus/#{name}"
      subject.create_topic topic
      subject.create_subscription topic, subscription
      subject.create_rule topic, subscription, rule
      subject.create_rule topic, subscription, rule1
      subject.create_rule topic, subscription, rule2
    end

    after do
      subject.delete_topic topic
      VCR.eject_cassette
    end

    it "should be able to use $skip token with rules" do
      result = subject.list_rules topic, subscription
      result2 = subject.list_rules topic, subscription, { :skip => 1 }
      result2.length.must_equal result.length - 1
      result2[0].id.must_equal result[1].id
    end

    it "should be able to use $top token with rules" do
      result = subject.list_rules topic, subscription
      result.length.wont_equal 1

      result2 = subject.list_rules topic, subscription, { :top => 1 }
      result2.length.must_equal 1
    end

    it "should be able to use $skip and $top token together with rules" do
      result = subject.list_rules topic, subscription
      result2 = subject.list_rules topic, subscription, { :skip => 1, :top => 1 }
      result2.length.must_equal 1
      result2[0].id.must_equal result[1].id
    end
  end
end
