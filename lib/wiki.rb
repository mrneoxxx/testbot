require 'wikipedia'

class Wiki
  class << self

    def search(text)
      Wikipedia.Configure {domain "#{I18n.locale}.wikipedia.org"}
      return Wikipedia.find(prepare_query(text))
    end

    # private

    def prepare_query(text)
      query = []
      %w(capitalize upcase downcase).each do |m|
        query << text.split(/[\s,-]/).map(&:mb_chars).map(&m.to_sym).map(&:to_s)
      end
      prepared_query = []
      query.each do |texts|
        prepared_query << texts.join(' ')
        prepared_query << texts.join('-')
      end
      return prepared_query.join('|')
    end
  end
end