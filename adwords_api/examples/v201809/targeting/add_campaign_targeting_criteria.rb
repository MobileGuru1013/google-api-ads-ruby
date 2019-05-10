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
# This example adds various types of targeting criteria to a campaign. To get
# campaigns list, run get_campaigns.rb.

require 'adwords_api'

def add_campaign_targeting_criteria(campaign_id, location_feed_id = nil)
  # AdwordsApi::Api will read a config file from ENV['HOME']/adwords_api.yml
  # when called without parameters.
  adwords = AdwordsApi::Api.new

  # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
  # the configuration file or provide your own logger:
  # adwords.logger = Logger.new('adwords_xml.log')

  campaign_criterion_srv =
      adwords.service(:CampaignCriterionService, API_VERSION)

  # Create campaign criteria.
  campaign_criteria = [
    # Location criteria. The IDs can be found in the documentation or retrieved
    # with the LocationCriterionService.
    {:xsi_type => 'Location', :id => 21137}, # California, USA
    {:xsi_type => 'Location', :id => 2484},  # Mexico
    # Language criteria. The IDs can be found in the documentation or retrieved
    # with the ConstantDataService.
    {:xsi_type => 'Language', :id => 1000},  # English
    {:xsi_type => 'Language', :id => 1003},  # Spanish
  ]

  # Distance targeting. Area of 10 miles around targets above.
  unless location_feed_id.nil?
    campaign_criteria << {
      :xsi_type => 'LocationGroups',
      :feed_id => location_feed_id,
      :matching_function => {
        :operator => 'IDENTITY',
        :lhs_operand => [{
          :xsi_type => 'LocationExtensionOperand',
          :radius => {
            :xsi_type => 'ConstantOperand',
            :type => 'DOUBLE',
            :unit => 'MILES',
            :double_value => 10
          }
        }]
      }
    }
  end

  # Create operations.
  operations = campaign_criteria.map do |criterion|
    {:operator => 'ADD',
     :operand => {
         :campaign_id => campaign_id,
         :criterion => criterion}
    }
  end

  # Add negative campaign criterion.
  operations << {
    :operator => 'ADD',
    :operand => {
      # The 'xsi_type' field allows you to specify the xsi:type of the object
      # being created. It's only necessary when you must provide an explicit
      # type that the client library can't infer.
      :xsi_type => 'NegativeCampaignCriterion',
      :campaign_id => campaign_id,
      :criterion => {
        :xsi_type => 'Keyword',
        :text => 'jupiter cruise',
        :match_type => 'BROAD'
      }
    }
  }

  response = campaign_criterion_srv.mutate(operations)

  if response and response[:value]
    criteria = response[:value]
    criteria.each do |campaign_criterion|
      criterion = campaign_criterion[:criterion]
      puts ("Campaign criterion with campaign ID %d, criterion ID %d and " +
          "type '%s' was added.") % [campaign_criterion[:campaign_id],
          criterion[:id], criterion[:criterion_type]]
    end
  else
    puts 'No criteria were returned.'
  end
end

if __FILE__ == $0
  API_VERSION = :v201809

  begin
    campaign_id = 'INSERT_CAMPAIGN_ID_HERE'
    # Replace the value below with the ID a feed that has been configured for
    # location targeting, meaning it has an ENABLED FeedMapping with
    # criterionType of 77. Feeds linked to a GMB account automatically
    # have this FeedMapping.
    # If you don't have such a feed, set this value to nil or delete
    # the variable.
    location_feed_id = 'INSERT_LOCATION_FEED_ID_HERE'
    add_campaign_targeting_criteria(campaign_id, location_feed_id)

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
