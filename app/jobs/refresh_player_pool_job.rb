class RefreshPlayerPoolJob < ApplicationJob
  queue_as :default

  POSITIONS = %w[QB RB WR TE K DST].freeze

  def perform(*args)
    Watir.default_timeout = 5
    prefs = {
      # download: {
      #   prompt_for_download: false,
      #   # default_directory: "/Fileserver/nas/video effects"
      #   default_directory: "/Volumes/Public/video effects"
      # },
      webkit: { webprefs: { loads_images_automatically: false } }
    }

    browser = Watir::Browser.new :chrome, options: { prefs: prefs }
    browser.goto 'https://www.fantasypros.com/nfl/rankings/consensus-cheatsheets.php'
    browser.elements(tag_name: 'div', class: 'player-cell').
      wait_until(&:exists?)

    # might be needed to ensure all rows are loaded
    sleep 10
    ranking_table = browser.table(id: "ranking-table")
    player_rows = ranking_table.trs(class: "player-row")
    Player.transaction do
      scraped_time = Time.current
      player_rows.each do |row|
        player = Player.new(scraped_at: scraped_time)

        row.each_with_index do |cell, cell_index|
          case cell_index
          when 2
            player.name = cell.a.text
            player.team = cell.span(class: "player-cell-team").text.gsub(/\W/, '')
          when 3
            if POSITIONS.include?(cell.text.gsub(/\d/, ""))
              player.position = cell.text.gsub(/\d/, "")
            end
          when 4
            player.bye_week = cell.text
          else
            next
          end
        end

        logger.info "Saving player: #{player.name}"
        player.save
      end
    end

    browser.close
  end
end
