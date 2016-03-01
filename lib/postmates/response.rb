require_relative 'utils'
require_relative 'quote'
require_relative 'delivery'

module Postmates
  module Response
    class << self
      include Postmates::Utils

      def build(body)
        kind = body.is_a?(Array) ? 'zones' : body['object'] || body['kind']
        case kind
        when 'list'
          body['data'].map { |del| Delivery.new(del) }.tap do |list|
            list.instance_variable_set(:@total_count, body['total_count'])
            list.instance_variable_set(:@next_href, urlify(body['next_href']))
            list.class.module_eval { attr_reader :total_count, :next_href }
          end
        when 'delivery'
          Delivery.new(body)
        when 'delivery_quote'
          Quote.new(body)
        when 'zones'
          body
        end
      end
    end
  end
end
