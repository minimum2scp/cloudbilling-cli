#! /usr/bin/env ruby

require 'json'
require 'pry'
require 'googleauth'
require 'google/apis/cloudbilling_v1'
require 'thor'
require 'dotenv/load'

class CloudbillingCli < Thor
  class_option :debug, aliases: %w[D], :type => :boolean

  desc "pry", "invoke pry shell"
  def pry
    binding.pry
  end

  desc "list", "list billing accounts"
  def list
    billing_accounts = api.fetch_all(items: :billing_accounts){ |token|
      api.list_billing_accounts(page_token: token)
    }.to_a
    puts JSON.pretty_generate(billing_accounts)
  end

  desc "get NAME", "get billing account"
  def get(name)
    billing_account = api.get_billing_account(name)
    puts JSON.pretty_generate(billing_account)
  end

  desc "get_iam_policy RESOURCE", "get billing account iam policy"
  def get_iam_policy(resource)
    policy = api.get_billing_account_iam_policy(resource)
    puts JSON.pretty_generate(policy)
  end

  desc "create displayName", "create billing account"
  option :master_billing_account, type: :string, default: nil
  def create(display_name)
    billing_account_object = Google::Apis::CloudbillingV1::BillingAccount.new(display_name: display_name)
    if options[:master_billing_account]
      billing_account_object.master_billing_account = options[:master_billing_account]
    end
    ret = api.create_billing_account(billing_account_object)
    puts JSON.pretty_generate(ret)
  end

  no_commands do
    def api
      @api ||= Google::Apis::CloudbillingV1::CloudbillingService.new.tap {|o|
        scopes = [Google::Apis::CloudbillingV1::AUTH_CLOUD_PLATFORM]
        o.authorization = Google::Auth.get_application_default(scopes)
        if options[:debug]
          o.client_options.transparent_gzip_decompression = false
          o.client_options.log_http_requests = true
          Google::Apis.logger.level = Logger::DEBUG
        end
      }
    end
  end
end

CloudbillingCli.start

