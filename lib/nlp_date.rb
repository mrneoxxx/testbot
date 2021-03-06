module NLPDate
  extend self

  MONTHS = {
    'січ' => 1,
    'лют' => 2,
    'бер' => 3,
    'кві' => 4,
    'тра' => 5,
    'чер' => 6,
    'лип' => 7,
    'сер' => 8,
    'вер' => 9,
    'жов' => 10,
    'лис' => 11,
    'гру' => 12
  }.freeze

  DATE = {
    'сьогодні' => Date.today,
    'завтра' => 1.days.from_now,
    'післязавтра' => 2.days.from_now
  }.freeze

  def parse(string)
    date = (Date.parse(string.to_s.strip) rescue nil)
    return date unless date.nil?
    date_hash = {}
    string.to_s.strip.split(' ').each do |word|
      word = word.to_s.strip.mb_chars.downcase.to_s
      next unless word.length > 0
      date = parse_full_date(word)
      break unless date.nil?
      %w(day month year).each do |type|
        type_data = send("parse_#{type}", word)
        date_hash[type.to_sym] = type_data unless type_data.nil?
      end
    end
    unless date_hash[:month].nil? || date_hash[:day].nil?
      date = Date.new(
        (date_hash[:year].nil? ? Date.today.year : date_hash[:year]),
        (date_hash[:month].nil? ? Date.today.month : date_hash[:month]),
        (date_hash[:day].nil? ? Date.today.day : date_hash[:day])
      ) rescue nil
    end
    return date
  end

  private

  def parse_full_date(word)
    return DATE[word] if DATE.keys.include?(word)
  end

  def parse_day(word)
    return word.to_i if word.to_i.to_s == word && word.to_i <= 31
  end

  def parse_month(word)
    return word.to_i if word.to_i.to_s == word && word.to_i <= 12
    return MONTHS[word[0,3]] if word.length >= 3
  end

  def parse_year(word)
    return word.to_i if word.to_i.to_s == word && word.length == 4
  end
end