require 'open-uri'
require 'nokogiri'

page_url = "http://scrapmaker.com/view/twelve-dicts/5desk.txt"

# retrieves the words from the site
page = Nokogiri::HTML(open(page_url)).css('pre').to_s

def clean_words(html)
  arr_of_words = html.split(/(>[a-z]+<)/).find_all { |x| x.match(/(>[a-z]+<)/) }

  arr_of_words.each do |word|
    word.gsub!(/\>|\</, '')
  end

  arr_of_words
end

list_of_words = clean_words(page)

# find a random word that's between 5 and 12 characters in length
random_word = list_of_words.find_all { |word| word.length > 5 && word.length < 12 }.sample
