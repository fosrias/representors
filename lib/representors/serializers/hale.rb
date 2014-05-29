module Representors
  module Serialization
    class HaleSerializer < HalSerializer

      include FormatSerializer

      symbol_format :hale
      iana_format 'application/vnd.hale+json'

      private

      def serialize(representor)
        base_hash, links, embedded_hales = common_serialization(representor)
        meta = get_data_lists(representor)
        ->(options) { base_hash.merge(meta).merge(links).merge(embedded_hales.(options)) }
      end

      def get_data_lists(representor)
        meta = {}
        representor.datalists.each do |datalist|
          meta[datalist.id] = datalist.as_data
        end
        meta.empty? ? {} : {'_meta' => meta }
      end

      def get_data_element(element)
        options = element.options.datalist? ? { '_ref' => [element.options.id] } : element.options
        element_data = element.to_hash[element.name]
        element_data[:options] = options
        { element.name => element_data }
      end

      def construct_links(transition)
        link = if transition.templated?
          { href:  transition.templated_uri, templated: true }
        else
          { href: transition.uri }
        end
        link[:method] = transition.interface_method
        data_elements = transition.attributes.reduce({}) do |results, element|
          results.merge( get_data_element(element) )
        end
        link[:data] = data_elements unless data_elements.empty?
        { transition.rel => link }
      end

    end
  end
end