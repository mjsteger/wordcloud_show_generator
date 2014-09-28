require 'nokogiri'
require 'open-uri'
TRANSCRIPT_URL = "http://www.springfieldspringfield.co.uk/"
TO_KEEP = 60
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
      text_array = text.join.gsub(/\r|\n|\[ [^\]]+ \]/x, "").scan(/\b[\w|']+\b/)
      hash = Hash.new { |hash, key| hash[key] = 0 }
      text_array.each { |x| hash[x]+= 1 }
      to_delete = %w(a the it of to and is this was I you me that on)
      to_delete + ('A'..'Z').to_a
      to_delete.each do |delete|
        hash.delete(delete.capitalize)
        hash.delete(delete.downcase)
      end
      # hash = Hash[hash.sort_by(&:last).last(TO_KEEP)]
      @word_array = hash.map { |(key, val)| {text: key, weight: val} }
    end
  end
end
