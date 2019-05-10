#!/usr/bin/env ruby
# Encoding: utf-8
#
# Copyright:: Copyright 2011, Google Inc. All Rights Reserved.
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
# Tests report utils.

require 'test/unit'

require 'adwords_api'

module AdwordsApi
  # Overriding default access levels to public for tests.
  class ReportUtils
    public :check_for_errors
    public :check_for_xml_error
    public :add_report_definition_hash_order
    public :check_report_definition_hash
    public :get_report_request_headers
    public :report_definition_to_xml
  end

  # Removing OAuth step so we can test header generation.
  class CredentialHandler
    def credentials(override = nil)
      {
        :client_customer_id => '123-456-7890',
        :developer_token => 'token'
      }
    end
  end
end

module AdsCommon
  module Auth
    class OAuth2Handler
      def auth_string(credentials)
      end
    end
  end
end

# Stub class for HTTP response.
class ResponseStub
  attr_reader :code
  attr_reader :body

  def initialize(code, body)
    @code, @body = code, body
  end
end

XML_REPLY = {
  :reply => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><reportDownloadError><ApiError><type>ReportDefinitionError.INVALID_FIELD_NAME_FOR_REPORT</type><trigger>foo</trigger><fieldPath>bar</fieldPath></ApiError></reportDownloadError>',
  :type => 'ReportDefinitionError.INVALID_FIELD_NAME_FOR_REPORT',
  :trigger => 'foo',
  :field_path => 'bar'
}

VALID_REPORT = '"Custom ADGROUP_PERFORMANCE_REPORT (Oct 20, 2011-Oct 26, 2011)"\nCampaign ID,Ad group ID,Impressions,Clicks,Cost\nTotal, --,0,0,0.00'
GZIPPED_REPORT = "\x1F\x8B\b\x00\x00\x00\x00\x00\x00\x00Sr.-.\xC9\xCFUptq\x0F\xF2\x0F\r\x88\x0Fp\rr\xF3\x0F\xF2u\xF4sv\x8D\x0Fr\r\xF0\x0F\nQ\xD0pIMV0\xD2Q0204\xD4\x05\xB1- lM%.\xE7\xC4\xDC\x82\xC4\xCC\xF4<\x05O\x17\x1D\xC7\x14\x85\xF4\xA2\xFC\xD2\x02\x10\xDB3\xB7\xA0(\xB5\xB883?\xAFX\xC79'39\eH\xE5\x17\x97p\x85\xE4\x97$\xE6\xE8(\xE8\xEA\xEA\x18\x80\xA0\x9E\x81\x01\x17\x00\xBE\x1D\xBE\xAD\x81\x00\x00\x00"

class TestReportUtils < Test::Unit::TestCase

  API_VERSION = :v201809

  # Initialize tests.
  def setup()
    @api = AdwordsApi::Api.new({
      :authentication => {
          :method => 'OAuth2',
          :oauth2_client_id => 'client_id123',
          :oauth2_client_secret => 'client_secret123',
          :developer_token => 'developer_token123',
          :client_customer_id => '012-345-6789',
          :user_agent => 'TestReportUtils'
      },
      :service => {
        :environment => 'PRODUCTION'
      }
    })
    @report_utils = @api.report_utils(API_VERSION)
  end

  # Testing HTTP code 400.
  def test_check_for_errors_400()
    e = assert_raise(AdwordsApi::Errors::ReportXmlError) do
      response = ResponseStub.new(400, XML_REPLY[:reply])
      @report_utils.check_for_errors(response)
    end
    assert_equal(400, e.http_code)
    assert_equal(XML_REPLY[:type], e.type)
    assert_equal(XML_REPLY[:trigger], e.trigger)
    assert_equal(XML_REPLY[:field_path], e.field_path)
    assert_not_nil(e.message)
  end

  # Testing HTTP code 500.
  def test_check_for_errors_500()
    e = assert_raise(AdwordsApi::Errors::ReportError) do
      response = ResponseStub.new(500, nil)
      @report_utils.check_for_errors(response)
    end
    assert_equal(500, e.http_code)
  end

  # Testing HTTP code 200 with success.
  def test_check_for_errors_200_success()
    response = ResponseStub.new(200, VALID_REPORT)
    assert_nothing_raised do
      @report_utils.check_for_errors(response)
    end
  end

  # Testing correct gzipped reply.
  def test_gzipped_data()
    report = (RUBY_VERSION >= '1.9.1') ?
        GZIPPED_REPORT.force_encoding('UTF-8') : GZIPPED_REPORT
    response = ResponseStub.new(200, report)
    assert_nothing_raised do
      @report_utils.check_for_errors(response)
    end
  end

  # Tests generated hash order for root (complete set).
  def test_add_report_definition_hash_order_root1()
    node = {
      :download_format => 'CSV',
      :report_type => 'CRITERIA_PERFORMANCE_REPORT',
      :selector => {},
      :report_name => 'report_name',
      :date_range_type => 'LAST_7_DAYS'
    }
    expected = [:selector, :report_name, :report_type, :date_range_type,
                :download_format]
    @report_utils.add_report_definition_hash_order(node)
    assert_not_nil(node[:order!])
    assert_equal(expected, node[:order!])
  end

  # Tests generated hash order for root (incomplete set).
  def test_add_report_definition_hash_order_root2()
    node = {
      :download_format => 'CSV',
      :report_type => 'CRITERIA_PERFORMANCE_REPORT',
      :selector => {},
      :report_name => 'report_name',
      :date_range_type => 'LAST_7_DAYS'
    }
    expected = [:selector, :report_name, :report_type, :date_range_type,
                :download_format]
    @report_utils.add_report_definition_hash_order(node)
    assert_not_nil(node[:order!])
    assert_equal(expected, node[:order!])
  end

  # Tests generated hash order for whole structure.
  def test_add_report_definition_hash_order_deep()
    node = {
      :report_name => 'report_name',
      :report_type => 'CRITERIA_PERFORMANCE_REPORT',
      :selector => {
        :date_range => {:max => '20120405', :min => '20120405'},
        :predicates => {:operator => 'IN', :field => 'S', :values => ['A']},
        :fields => ['CampaignId']
      },
      :download_format => 'CSV',
      :date_range_type => 'LAST_7_DAYS'
    }
    expected1 = [:selector, :report_name, :report_type, :date_range_type,
                 :download_format]
    expected2 = [:fields, :predicates, :date_range]
    expected3 = [:min, :max]
    expected4 = [:field, :operator, :values]

    @report_utils.add_report_definition_hash_order(node)
    assert_not_nil(node[:order!])
    assert_not_nil(node[:selector][:order!])
    assert_not_nil(node[:selector][:date_range][:order!])
    assert_not_nil(node[:selector][:predicates][:order!])

    assert_equal(expected1, node[:order!])
    assert_equal(expected2, node[:selector][:order!])
    assert_equal(expected3, node[:selector][:date_range][:order!])
    assert_equal(expected4, node[:selector][:predicates][:order!])
  end

  # Testing error message for invalid fields.
  def test_invalid_fields_in_hash()
    report_definition = {
      :report_name => 'report_name',
      :report_type => 'CRITERIA_PERFORMANCE_REPORT',
      :selector => {
        :date_range => {:max => '20120405', :min => '20120405'},
        :predicates => {:operator => 'IN', :field => 'S', :values => ['A']},
        :fields => ['CampaignId'],
        :invalid_field => 'some_value'
      },
      :download_format => 'CSV',
      :date_range_type => 'LAST_7_DAYS'
    }
    expected_message = "Unknown report definition field(s): [:invalid_field]"

    assert_nothing_raised do
      begin
        @report_utils.report_definition_to_xml(report_definition)
      rescue AdwordsApi::Errors::InvalidReportDefinitionError => e
        assert_equal(expected_message, e.message)
      end
    end
  end

  # Testing check_for_xml_error.
  def test_check_for_xml_error()
    e = assert_raise(AdwordsApi::Errors::ReportXmlError) do
      @report_utils.check_for_xml_error(XML_REPLY[:reply], 42)
    end
    assert_equal(42, e.http_code)
    assert_equal(XML_REPLY[:type], e.type)
    assert_equal(XML_REPLY[:trigger], e.trigger)
    assert_equal(XML_REPLY[:field_path], e.field_path)
    assert_not_nil(e.message)
  end

  def test_check_for_xml_error_with_message()
    http_code = 442
    e = assert_raise(AdwordsApi::Errors::ReportXmlError) do
      @report_utils.check_for_xml_error(XML_REPLY[:reply], http_code)
    end
    error_str = e.to_s
    assert(error_str.include?(http_code.to_s),
        'HTTP code was not passed to the error message')
    assert(error_str.include?(XML_REPLY[:type]),
        'Error type was not passed to the error message')
    assert(error_str.include?(XML_REPLY[:trigger]),
        'Error trigger was not passed to the error message')
    assert(error_str.include?(XML_REPLY[:field_path]),
        'Field path was not passed to the error message')
  end

  def test_skip_report()
    headers = @report_utils.get_report_request_headers(nil, nil)
    assert_nil(headers['skipReportHeader'])
    @api.skip_report_header = true
    headers = @report_utils.get_report_request_headers(nil, nil)
    assert_equal('true', headers['skipReportHeader'])
  end

  def test_skip_report_summary()
    headers = @report_utils.get_report_request_headers(nil, nil)
    assert_nil(headers['skipReportSummary'])
    @api.skip_report_summary = true
    headers = @report_utils.get_report_request_headers(nil, nil)
    assert_equal('true', headers['skipReportSummary'])
  end

  def test_skip_column_header()
    headers = @report_utils.get_report_request_headers(nil, nil)
    assert_nil(headers['skipColumnHeader'])
    @api.skip_column_header = true
    headers = @report_utils.get_report_request_headers(nil, nil)
    assert_equal('true', headers['skipColumnHeader'])
  end

  def test_include_zero_impressions()
    headers = @report_utils.get_report_request_headers(nil, nil)
    assert_nil(headers['includeZeroImpressions'])
    @api.include_zero_impressions = true
    headers = @report_utils.get_report_request_headers(nil, nil)
    assert_equal('true', headers['includeZeroImpressions'])
  end

  def test_use_raw_enum_values()
    headers = @report_utils.get_report_request_headers(nil, nil)
    assert_nil(headers['useRawEnumValues'])
    @api.use_raw_enum_values = true
    headers = @report_utils.get_report_request_headers(nil, nil)
    assert_equal('true', headers['useRawEnumValues'])
  end
end
