require 'nokogiri'
require 'open-uri'
TRANSCRIPT_URL = "http://www.springfieldspringfield.co.uk/"
TO_KEEP = 150
SIZE_FACTOR = 10
class WordcloudController < ApplicationController
  def view
    return unless params[:tv_show]
    tv_show = params[:tv_show]
    url = "#{TRANSCRIPT_URL}episode_scripts.php?tv-show=#{tv_show}"
    doc = Nokogiri::HTML(open(url))
    if params[:season]
      current_season, _  = doc.css('.season-episodes').search "h3[id=\"#{params[:season]}\"]"
        @episodes = Hash[current_season.parent.css(".season-episode-title").map {|href| [href.text, href.attributes["href"].value]}]
    else
      @seasons = doc.css('.season-episodes').css("h3").map {|h3| h3.attributes["id"].value }
    end


    if params[:episode]
      transcript_href = TRANSCRIPT_URL + @episodes[params[:episode]]
      episode_transcript = Nokogiri::HTML(open(transcript_href))
      text = episode_transcript.css(".scrolling-script-container").children.map(&:text)
      text_array = text.
        join.
        encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').
        gsub(/\r|\n|\[ [^\]]+ \]/x, "").
        scan(/\b[\w|']+\b/).
        map(&:downcase)
      hash = Hash.new { |hash, key| hash[key] = 0 }
      text_array.each { |x| hash[x]+= 1 }
      to_delete = %w(a the it of to and is this was I you me that on it's what that that's in for if by did my have so do be your I'm I'll her his can are an he as our at but she you're but or we not too has her him can am had i've well will let off we're we've he's)
      to_delete = to_delete + ('A'..'Z').to_a
      to_delete.each do |delete|
        hash.delete(delete.capitalize)
        hash.delete(delete)
        hash.delete(delete.downcase)
      end
      to_keep = params[:to_keep] || TO_KEEP
      hash = Hash[hash.sort_by(&:last).last(to_keep)]
      params[:visualization] ||= "instant"
      value_key = params[:visualization] == "instant" ? :size : :weight
      @word_array = hash.map { |(key, val)| {text: key, value_key => (val * 3) + SIZE_FACTOR} }
    end
  end
end
