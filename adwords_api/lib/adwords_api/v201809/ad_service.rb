# Encoding: utf-8
#
# This is auto-generated code, changes will be overwritten.
#
# Copyright:: Copyright 2018, Google Inc. All Rights Reserved.
# License:: Licensed under the Apache License, Version 2.0.
#
# Code generated by AdsCommon library 1.0.1 on 2018-09-20 09:46:55.

require 'ads_common/savon_service'
require 'adwords_api/v201809/ad_service_registry'

module AdwordsApi; module V201809; module AdService
  class AdService < AdsCommon::SavonService
    def initialize(config, endpoint)
      namespace = 'https://adwords.google.com/api/adwords/cm/v201809'
      super(config, endpoint, namespace, :v201809)
    end

    def get(*args, &block)
      return execute_action('get', args, &block)
    end

    def get_to_xml(*args)
      return get_soap_xml('get', args)
    end

    def mutate(*args, &block)
      return execute_action('mutate', args, &block)
    end

    def mutate_to_xml(*args)
      return get_soap_xml('mutate', args)
    end

    private

    def get_service_registry()
      return AdServiceRegistry
    end

    def get_module()
      return AdwordsApi::V201809::AdService
    end
  end
end; end; end
