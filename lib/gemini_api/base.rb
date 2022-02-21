# frozen_string_literal: true

require 'base64'
require 'dotenv/load'
require 'httparty'
require 'json'
require 'recursive-open-struct'
require 'uri'
require_relative '../concerns/environmentable'

module GeminiApi
  # Parent class for Gemini API interface. Classes which inherit the parent class generally represent an HTTP method.
  class Base
    include Environmentable

    API_ENVIRONMENTS =
      RecursiveOpenStruct.new(
        live: {
          scheme: 'https://',
          hostname: 'api.gemini.com',
          api_key_env_name: 'GEMINI_API_KEY',
          api_secret_env_name: 'GEMINI_API_SECRET'
        },
        sandbox: {
          scheme: 'https://',
          hostname: 'api.sandbox.gemini.com',
          api_key_env_name: 'GEMINI_SANDBOX_API_KEY',
          api_secret_env_name: 'GEMINI_SANDBOX_API_SECRET'
        }
      ).freeze
    API_VERSIONS = %w[v1].freeze

    def initialize(api_version: 'v1', **attributes)
      validate_and_assign_environment_details(attributes[:environment])
      validate_and_assign_api_credentials
      validate_and_assign_version_and_endpoints(api_version)
    end

    private

    attr_accessor :api_key, :api_secret, :endpoints, :hostname, :scheme, :version

    def validate_and_assign_environment_details(environment_value)
      raise ArgumentError, "Environment must be one of the following: #{ENVIRONMENTS.join(', ')}" unless ENVIRONMENTS.include?(environment_value)

      self.environment = environment_value
      self.hostname = API_ENVIRONMENTS[environment].hostname
      self.scheme = API_ENVIRONMENTS[environment].scheme
    end

    def validate_and_assign_version_and_endpoints(api_version_value)
      raise ArgumentError, "API version must be one of the following: #{API_VERSIONS.join(', ')}" unless API_VERSIONS.include?(api_version_value)

      self.version = api_version_value
      self.endpoints = RecursiveOpenStruct.new(YAML.load_file(File.join(__dir__, 'fixtures/endpoints.yml'))[version])
    end

    def validate_and_assign_api_credentials
      Dotenv.require_keys(
        API_ENVIRONMENTS[environment].api_key_env_name,
        API_ENVIRONMENTS[environment].api_secret_env_name
      )

      self.api_key = ENV[API_ENVIRONMENTS[environment].api_key_env_name]
      self.api_secret = ENV[API_ENVIRONMENTS[environment].api_secret_env_name]
    end

    def base64_encoded_json(object)
      Base64.strict_encode64(object.to_json)
    end

    def headers(payload:, signature:)
      {
        'Content-Type': 'text/plain',
        'Content-Length': '0',
        'X-GEMINI-APIKEY': api_key,
        'X-GEMINI-PAYLOAD': payload,
        'X-GEMINI-SIGNATURE': signature,
        'Cache-Control': 'no-cache'
      }
    end

    def request(http_method:, endpoint_key:, resource: nil, payload_options: {})
      encoded_payload =
        base64_encoded_json(
          payload(endpoints.send(endpoint_key), resource) { payload_options }
        )

      response =
        HTTParty.send(
          http_method,
          url(endpoints.send(endpoint_key), resource),
          headers: headers(payload: encoded_payload, signature: signature(encoded_payload))
        )

      RecursiveOpenStruct.new({ body: response.parsed_response, code: response.code, response_at: Time.parse(response.headers['date']) }, recurse_over_arrays: true)
    end

    def payload(endpoint, resource)
      {
        nonce: payload_nonce,
        request: File.join([endpoint, resource].compact),
        **(block_given? ? yield : {})
      }
    end

    def payload_nonce
      seconds_to_milliseconds(Time.now.to_f).floor(0)
    end

    def seconds_to_milliseconds(seconds)
      seconds * 1_000
    end

    def signature(data)
      OpenSSL::HMAC.hexdigest('sha384', api_secret, data)
    end

    def url(*path)
      URI.join("#{scheme}#{hostname}", File.join(path.compact))
    end
  end
end
