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
# This example demonstrates how to handle partial failures.

require 'adwords_api'

def handle_partial_failures(ad_group_id)
  # AdwordsApi::Api will read a config file from ENV['HOME']/adwords_api.yml
  # when called without parameters.
  adwords = AdwordsApi::Api.new

  # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
  # the configuration file or provide your own logger:
  # adwords.logger = Logger.new('adwords_xml.log')

  ad_group_criterion_srv =
      adwords.service(:AdGroupCriterionService, API_VERSION)

  # Set partial failures flag.
  adwords.partial_failure = true

  # Create keywords.
  keyword_text = ['mars cruise', 'inv@lid cruise', 'venus cruise',
                  'b(a)d keyword cruise']
  keywords = []
  keyword_text.each do |text|
    keyword = {
      # The 'xsi_type' field allows you to specify the xsi:type of the object
      # being created. It's only necessary when you must provide an explicit
      # type that the client library can't infer.
      :xsi_type => 'Keyword',
      :match_type => 'BROAD',
      :text => text
    }
    keywords << keyword
  end

  # Create biddable ad group criteria and operations.
  operations = []
  keywords.each do |kwd|
    operation = {
      :operator => 'ADD',
      :operand => {
        :xsi_type => 'BiddableAdGroupCriterion',
        :ad_group_id => ad_group_id,
        :criterion => kwd
      }
    }
    operations << operation
  end

  # Add ad group criteria.
  response = ad_group_criterion_srv.mutate(operations)

  # Display results.
  if response and response[:value]
    ad_group_criteria = response[:value]
    ad_group_criteria.each do |ad_group_criterion|
      if ad_group_criterion[:criterion]
        puts ("Ad group criterion with ad group id %d, criterion id %d, and " +
            " keyword '%s' was added.") % [
              ad_group_criterion[:ad_group_id],
              ad_group_criterion[:criterion][:id],
              ad_group_criterion[:criterion][:text]
            ]
      end
    end
  else
    puts "No criteria were added."
  end

  # Check partial failures.
  if response and response[:partial_failure_errors]
    response[:partial_failure_errors].each do |error|
      field_path_elements = error[:field_path_elements]
      first_field_path_element = nil
      unless field_path_elements.nil? || field_path_elements.length <= 0
        first_field_path_element = field_path_elements.first
      end
      if !first_field_path_element.nil? &&
          'operations' == first_field_path_element[:field] &&
          first_field_path_element[:index] != nil
        operation_index = first_field_path_element[:index]
        ad_group_criterion = operations[operation_index][:operand]
        puts ("Ad group criterion with ad group id %d and keyword '%s' " +
            "triggered an error for the following reason: %s") % [
              ad_group_criterion[:ad_group_id],
              ad_group_criterion[:criterion][:text],
              error[:error_string]
            ]
      else
        puts "A failure has occurred for the following reason: '%s'" %
            error[:error_string]
      end
    end
  end
end

if __FILE__ == $0
  API_VERSION = :v201809

  begin
    ad_group_id = 'INSERT_AD_GROUP_ID_HERE'.to_i
    handle_partial_failures(ad_group_id)

  # Authorization error.
  rescue AdsCommon::Errors::OAuth2VerificationRequired => e
    puts "Authorization credentials are not valid. Edit adwords_api.yml for " +
        "OAuth2 client ID and secret and run misc/setup_oauth2.rb example " +
        "to retrieve and store OAuth2 tokens."
    puts "See this wiki page for more details:\n\n  " +
        'https://github.com/googleads/google-api-ads-ruby/wiki/OAuth2'

  # HTTP errors.
  rescue AdsCommon::Errors::HttpError => e
    puts "HTTP Error: %s" % e

  # API errors.
  rescue AdwordsApi::Errors::ApiException => e
    puts "Message: %s" % e.message
    puts 'Errors:'
    e.errors.each_with_index do |error, index|
      puts "\tError [%d]:" % (index + 1)
      error.each do |field, value|
        puts "\t\t%s: %s" % [field, value]
      end
    end
  end
end
