# Encoding: utf-8
#
# This is auto-generated code, changes will be overwritten.
#
# Copyright:: Copyright 2018, Google Inc. All Rights Reserved.
# License:: Licensed under the Apache License, Version 2.0.
#
# Code generated by AdsCommon library 1.0.1 on 2018-09-20 09:47:31.

require 'ads_common/savon_service'
require 'adwords_api/v201809/managed_customer_service_registry'

module AdwordsApi; module V201809; module ManagedCustomerService
  class ManagedCustomerService < AdsCommon::SavonService
    def initialize(config, endpoint)
      namespace = 'https://adwords.google.com/api/adwords/mcm/v201809'
      super(config, endpoint, namespace, :v201809)
    end

    def get(*args, &block)
      return execute_action('get', args, &block)
    end

    def get_to_xml(*args)
      return get_soap_xml('get', args)
    end

    def get_pending_invitations(*args, &block)
      return execute_action('get_pending_invitations', args, &block)
    end

    def get_pending_invitations_to_xml(*args)
      return get_soap_xml('get_pending_invitations', args)
    end

    def mutate(*args, &block)
      return execute_action('mutate', args, &block)
    end

    def mutate_to_xml(*args)
      return get_soap_xml('mutate', args)
    end

    def mutate_label(*args, &block)
      return execute_action('mutate_label', args, &block)
    end

    def mutate_label_to_xml(*args)
      return get_soap_xml('mutate_label', args)
    end

    def mutate_link(*args, &block)
      return execute_action('mutate_link', args, &block)
    end

    def mutate_link_to_xml(*args)
      return get_soap_xml('mutate_link', args)
    end

    def mutate_manager(*args, &block)
      return execute_action('mutate_manager', args, &block)
    end

    def mutate_manager_to_xml(*args)
      return get_soap_xml('mutate_manager', args)
    end

    private

    def get_service_registry()
      return ManagedCustomerServiceRegistry
    end

    def get_module()
      return AdwordsApi::V201809::ManagedCustomerService
    end
  end
end; end; end
