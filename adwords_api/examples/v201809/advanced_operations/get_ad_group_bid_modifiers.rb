#!/usr/bin/env ruby
# Encoding: utf-8
#
# Copyright:: Copyright 2013, Google Inc. All Rights Reserved.
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
# This example illustrates how to retrieve ad group level bid modifiers for a
# campaign.

require 'adwords_api'

def get_ad_group_bid_modifiers(campaign_id)
  # AdwordsApi::Api will read a config file from ENV['HOME']/adwords_api.yml
  # when called without parameters.
  adwords = AdwordsApi::Api.new

  # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
  # the configuration file or provide your own logger:
  # adwords.logger = Logger.new('adwords_xml.log')

  bid_modifier_srv = adwords.service(:AdGroupBidModifierService, API_VERSION)

  # Get all ad group bid modifiers for the campaign.
  selector = {
    :fields => ['CampaignId', 'AdGroupId', 'Id', 'BidModifier'],
    :predicates => [
      {:field => 'CampaignId', :operator => 'EQUALS', :values => [campaign_id]}
    ],
    :paging => {
      :start_index => 0,
      :number_results => PAGE_SIZE
    }
  }

  # Set initial values.
  offset, page = 0, {}

  begin
    page = bid_modifier_srv.get(selector)
    if page[:entries]
      page[:entries].each do |modifier|
        value = modifier[:bid_modifier] || 'unset'
        puts ('Campaign ID %d, AdGroup ID %d, Criterion ID %d has ad group ' +
           'level modifier: %s') %
           [modifier[:campaign_id], modifier[:ad_group_id],
            modifier[:criterion][:id], value]
      end
      # Increment values to request the next page.
      offset += PAGE_SIZE
      selector[:paging][:start_index] = offset
    else
      puts 'No ad group level bid overrides returned.'
    end
  end while page[:total_num_entries] > offset
end

if __FILE__ == $0
  API_VERSION = :v201809
  PAGE_SIZE = 500

  begin
    # ID of a campaign to pull overrides for.
    campaign_id = 'INSERT_CAMPAIGN_ID_HERE'.to_i

    get_ad_group_bid_modifiers(campaign_id)

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
