# Encoding: utf-8
#
# This is auto-generated code, changes will be overwritten.
#
# Copyright:: Copyright 2019, Google Inc. All Rights Reserved.
# License:: Licensed under the Apache License, Version 2.0.
#
# Code generated by AdsCommon library 1.0.2 on 2019-02-07 14:55:15.

require 'ads_common/savon_service'
require 'ad_manager_api/v201902/premium_rate_service_registry'

module AdManagerApi; module V201902; module PremiumRateService
  class PremiumRateService < AdsCommon::SavonService
    def initialize(config, endpoint)
      namespace = 'https://www.google.com/apis/ads/publisher/v201902'
      super(config, endpoint, namespace, :v201902)
    end

    def create_premium_rates(*args, &block)
      return execute_action('create_premium_rates', args, &block)
    end

    def create_premium_rates_to_xml(*args)
      return get_soap_xml('create_premium_rates', args)
    end

    def get_premium_rates_by_statement(*args, &block)
      return execute_action('get_premium_rates_by_statement', args, &block)
    end

    def get_premium_rates_by_statement_to_xml(*args)
      return get_soap_xml('get_premium_rates_by_statement', args)
    end

    def update_premium_rates(*args, &block)
      return execute_action('update_premium_rates', args, &block)
    end

    def update_premium_rates_to_xml(*args)
      return get_soap_xml('update_premium_rates', args)
    end

    private

    def get_service_registry()
      return PremiumRateServiceRegistry
    end

    def get_module()
      return AdManagerApi::V201902::PremiumRateService
    end
  end
end; end; end
