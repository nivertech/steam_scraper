require_relative './page_retriever.rb'

# Class that scrapes a games actual page
class GamePageScraper
  def initialize(*_args)
    @page_retriever = PageRetriever.new
  end

  def scrape(games_hash)
    games_hash.map! do |game|
      url = game[:url]
      scrape_game!(game, url) unless url.nil?
    end
    games_hash
  end

  def scrape_game!(game, url)
    puts 'Scraping Page for ' + game[:name]
    page_contents = get_page_contents(url)
    game[:metacritic] = scrape_metacritic(page_contents)
    game[:tags] = scrape_tags(page_contents)
    game[:genres] = scrape_genres(page_contents)
    game[:developer] = scrape_developer(page_contents)
    game[:publisher] = scrape_publisher(page_contents)
    game[:min_spec] = scrape_min_spec(page_contents)
    game[:recommended_spec] = scrape_recommended_spec(page_contents)

    game
  end

  def get_page_contents(url)
    @page_retriever.retrieve(url)
  end

  def scrape_metacritic(page_contents)
    score_element = page_contents.xpath("//div[@id='game_area_metascore']/span").first
    score_element.text.to_i unless score_element.nil?
  end

  def scrape_tags(page_contents)
    tags = []
    page_contents.xpath("//div[contains(@class, 'popular_tags')]/a").each do |tag|
      tags.push(tag.text.strip)
    end

    tags
  end

  def scrape_genres(page_contents)
    genres = []
    details = page_contents.xpath("//div[@class='details_block']")
    details.xpath(".//a[contains(@href, 'genre')]").each do |genre|
      genres.push(genre.text.strip)
    end

    genres
  end

  def scrape_developer(page_contents)
    details = page_contents.xpath("//div[@class='details_block']")
    details.xpath(".//a[contains(@href, 'developer')]").text.strip
  end

  def scrape_publisher(page_contents)
    details = page_contents.xpath("//div[@class='details_block']")
    details.xpath(".//a[contains(@href, 'publisher')]").text.strip
  end

  def scrape_min_spec(page_contents)
    spec_block = page_contents.xpath("//div[@data-os='win']/div[@class='game_area_sys_req_leftCol']/ul/ul")
    scrape_spec(spec_block)
  end

  def scrape_recommended_spec(page_contents)
    spec_block = page_contents.xpath("//div[@data-os='win']/div[@class='game_area_sys_req_rightCol']/ul/ul")
    scrape_spec(spec_block)
  end

  def scrape_spec(node)
    spec_array = node.text.split "\r"
    spec_hash = {}
    spec_array.each do |entry|
      value_pair = entry.split(':')
      key = value_pair.first.to_sym
      value = value_pair.last.strip
      spec_hash[key] = value
    end

    spec_hash
  end
end