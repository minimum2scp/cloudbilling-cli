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

  no_commands do
    def api
      @api ||= Google::Apis::CloudbillingV1::CloudbillingService.new.tap {|o|
        scopes = [Google::Apis::CloudbillingV1::AUTH_CLOUD_PLATFORM]
        o.authorization = Google::Auth.get_application_default(scopes)
        if options[:debug]
          Google::Apis.logger.level = Logger::DEBUG
        end
      }
    end
  end
end

CloudbillingCli.start

