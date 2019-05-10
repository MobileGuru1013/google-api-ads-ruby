# Encoding: utf-8
#
# This is auto-generated code, changes will be overwritten.
#
# Copyright:: Copyright 2018, Google Inc. All Rights Reserved.
# License:: Licensed under the Apache License, Version 2.0.
#
# Code generated by AdsCommon library 1.0.1 on 2018-08-02 14:04:35.

require 'ads_common/savon_service'
require 'ad_manager_api/v201808/product_package_service_registry'

module AdManagerApi; module V201808; module ProductPackageService
  class ProductPackageService < AdsCommon::SavonService
    def initialize(config, endpoint)
      namespace = 'https://www.google.com/apis/ads/publisher/v201808'
      super(config, endpoint, namespace, :v201808)
    end

    def create_product_packages(*args, &block)
      return execute_action('create_product_packages', args, &block)
    end

    def create_product_packages_to_xml(*args)
      return get_soap_xml('create_product_packages', args)
    end

    def get_product_packages_by_statement(*args, &block)
      return execute_action('get_product_packages_by_statement', args, &block)
    end

    def get_product_packages_by_statement_to_xml(*args)
      return get_soap_xml('get_product_packages_by_statement', args)
    end

    def perform_product_package_action(*args, &block)
      return execute_action('perform_product_package_action', args, &block)
    end

    def perform_product_package_action_to_xml(*args)
      return get_soap_xml('perform_product_package_action', args)
    end

    def update_product_packages(*args, &block)
      return execute_action('update_product_packages', args, &block)
    end

    def update_product_packages_to_xml(*args)
      return get_soap_xml('update_product_packages', args)
    end

    private

    def get_service_registry()
      return ProductPackageServiceRegistry
    end

    def get_module()
      return AdManagerApi::V201808::ProductPackageService
    end
  end
end; end; end
