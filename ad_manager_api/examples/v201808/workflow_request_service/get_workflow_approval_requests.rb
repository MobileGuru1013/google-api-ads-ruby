#!/usr/bin/env ruby
# Encoding: utf-8
#
# Copyright:: Copyright 2016, Google Inc. All Rights Reserved.
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
# This example gets workflow approval requests. Workflow approval requests must
# be approved or rejected for a workflow to finish.

require 'ad_manager_api'

def get_workflow_approval_requests(ad_manager)
  # Get the WorkflowRequestService.
  workflow_request_service = ad_manager.service(
      :WorkflowRequestService, API_VERSION
  )

  # Create a statement to select workflow requests.
  statement = ad_manager.new_statement_builder do |sb|
    sb.where = 'type = :type'
    sb.with_bind_variable('type', 'WORKFLOW_APPROVAL_REQUEST')
  end

  # Retrieve a small amount of workflow requests at a time, paging
  # through until all workflow requests have been retrieved.
  page = {:total_result_set_size => 0}
  begin
    page = workflow_request_service.get_workflow_requests_by_statement(
        statement.to_statement()
    )

    # Print out some information for each workflow request.
    unless page[:results].nil?
      page[:results].each_with_index do |workflow_request, index|
        puts ('%d) Workflow request with ID %d, entity type "%s", and entity ' +
            'ID %d was found.') % [index + statement.offset,
            workflow_request[:id], workflow_request[:entity_type],
            workflow_request[:entity_id]]
      end
    end

    # Increase the statement offset by the page size to get the next page.
    statement.offset += statement.limit
  end while statement.offset < page[:total_result_set_size]

  puts 'Total number of workflow requests: %d' % page[:total_result_set_size]
end

if __FILE__ == $0
  API_VERSION = :v201808

  # Get AdManagerApi instance and load configuration from ~/ad_manager_api.yml.
  ad_manager = AdManagerApi::Api.new

  # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
  # the configuration file or provide your own logger:
  # ad_manager.logger = Logger.new('ad_manager_xml.log')

  begin
    get_workflow_approval_requests(ad_manager)

  # HTTP errors.
  rescue AdsCommon::Errors::HttpError => e
    puts "HTTP Error: %s" % e

  # API errors.
  rescue AdManagerApi::Errors::ApiException => e
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
