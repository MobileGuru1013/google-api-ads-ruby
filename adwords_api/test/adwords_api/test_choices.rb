#!/usr/bin/env ruby
# Encoding: utf-8
#
# Copyright:: Copyright 2014, Google Inc. All Rights Reserved.
#
# License:: Licensed under the Apache License, Version 2.0 (the "License");
#           you may not use this file except in compliance with the License.
#           You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#           Unless required by applicable law or agreed to in writing, software
#           distributed under the License is distributed on an "AS IS" BASIS,
#           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#           implied.
#           See the License for the specific language governing permissions and
#           limitations under the License.
#
# Tests choices type in the request.

require 'test/unit'

require 'ads_common/parameters_validator'
require 'adwords_api/v201809/adwords_user_list_service_registry'

class TestChoices < Test::Unit::TestCase

  def setup()
    registry_module = AdwordsApi::V201809::AdwordsUserListService
    registry = registry_module::AdwordsUserListServiceRegistry
    @validator = AdsCommon::ParametersValidator.new(registry)
  end

  def test_choices_one()
    op = get_op_for_items([
      {
        :xsi_type => 'NumberRuleItem',
        :key => {:name => 'foo'}, :op => 'EQUALS', :value => 42
      }
    ])
    expected = get_expected_for_items([
      {
        'NumberRuleItem' => {
          :key => {:name => 'foo', :'order!' => [:name]},
          :op => 'EQUALS', :value => 42, :'order!' => [:key, :op, :value]},
        :'attributes!' => {
          'NumberRuleItem' => {'xsi:type' => 'NumberRuleItem'}
        },
      }
    ])
    result = @validator.validate_args('mutate', [[op]])[:operations][0]
    assert_equal(expected, result[:operand][:rule])
  end

  def test_choices_multiple_of_same_type()
    op = get_op_for_items([
      {:xsi_type => 'NumberRuleItem',
       :key => {:name => 'foo'}, :op => 'EQUALS', :value => 42},
      {:xsi_type => 'NumberRuleItem',
       :key => {:name => 'bar'}, :op => 'EQUALS', :value => 84}
    ])
    expected = get_expected_for_items([
      {
        'NumberRuleItem' => {
          :key => {:name => 'foo', :'order!' => [:name]},
          :op => 'EQUALS', :value => 42, :'order!' => [:key, :op, :value]
        },
        :'attributes!' => {
          'NumberRuleItem' => {'xsi:type' => 'NumberRuleItem'}
        }
      },
      {
        'NumberRuleItem' => {
          :key => {:name => 'bar', :'order!' => [:name]},
          :op => 'EQUALS', :value => 84, :'order!' => [:key, :op, :value]
        },
        :'attributes!' => {
          'NumberRuleItem' => {'xsi:type' => 'NumberRuleItem'}
        }
      }
    ])
    result = @validator.validate_args('mutate', [[op]])[:operations][0]
    assert_equal(expected, result[:operand][:rule])
  end

  def test_choices_different_types()
    op = get_op_for_items([
      {:xsi_type => 'NumberRuleItem',
       :key => {:name => 'foo'}, :op => 'EQUALS', :value => 42},
      {:xsi_type => 'StringRuleItem',
       :key => {:name => 'bar'}, :op => 'EQUALS', :value => 'baz'}
    ])
    expected = get_expected_for_items([
      {
          'NumberRuleItem' => {
            :key => {:name => 'foo', :'order!' => [:name]},
            :op => 'EQUALS', :value => 42, :'order!' => [:key, :op, :value]
          },
          :'attributes!' => {
            'NumberRuleItem' => {'xsi:type' => 'NumberRuleItem'}
          }
      },
      {
          'StringRuleItem' => {
            :key => {:name => 'bar', :'order!' => [:name]},
            :op => 'EQUALS', :value => 'baz',
            :'order!' => [:key, :op, :value]
          },
          :'attributes!' => {
            'StringRuleItem' => {'xsi:type' => 'StringRuleItem'}
          }
      }
    ])
    result = @validator.validate_args('mutate', [[op]])[:operations][0]
    assert_equal(expected, result[:operand][:rule])
  end

  def test_choices_wrong_xsi_type()
    op = get_op_for_items([
      {:xsi_type => 'FooRuleItem',
       :key => {:name => 'foo'}, :op => 'EQUALS', :value => 42}
    ])
    assert_raise AdsCommon::Errors::TypeMismatchError do
      @validator.validate_args('mutate', [[op]])
    end
  end

  def test_choices_missing_xsi_type()
    op = get_op_for_items([
      {:key => {:name => 'foo'}, :op => 'EQUALS', :value => 42}
    ])
    assert_raise AdsCommon::Errors::TypeMismatchError do
      @validator.validate_args('mutate', [[op]])
    end
  end

  def test_inherited_choices()
    result = nil
    op = {
      :operator => 'ADD',
      :operand => {
        :xsi_type => 'LogicalUserList',
        :name => 'Sample Logical List',
        :status => 'OPEN',
        :rules => [
          {
            :operator => 'ANY',
            :rule_operands => [
              {:xsi_type => 'LogicalUserList', :id => 123456781},
              {:xsi_type => 'BasicUserList', :id => 123456782},
              {:xsi_type => 'LogicalUserList', :id => 123456783},
              {:xsi_type => 'ExpressionRuleUserList', :id => 123456784}
            ]
          }
        ]
      }
    }
    assert_nothing_raised do
      result = @validator.validate_args('mutate', [[op]])
    end

    assert_not_nil(result)
    assert_kind_of(Array,
        result[:operations][0][:operand][:rules][0][:rule_operands])

    list = result[:operations][0][:operand][:rules][0][:rule_operands]
    expected = ['LogicalUserList', 'BasicUserList', 'LogicalUserList',
        'ExpressionRuleUserList']
    expected.each_with_index do |name, i|
      assert_equal(name, list[i][:'attributes!']['UserList']['xsi:type'])
    end
  end

  private

  def get_op_for_items(items)
    return {
      :operator => 'ADD',
      :operand => {
        :xsi_type => 'ExpressionRuleUserList',
        :name => 'choices test',
        :description => 'A list of mars cruise customers in the last year',
        :rule => {:groups => [{:items => items}]}
      }
    }
  end

  def get_expected_for_items(items)
    return {
      :groups => [
        {
          :items => items,
          :'order!' => [:items]
        }
      ],
      :'order!' => [:groups]
    }
  end
end
