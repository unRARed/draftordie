class RefreshIdpPoolJob < ApplicationJob
  queue_as :default

  POSITIONS = %w[LB S DE CB DT].freeze

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
    browser.goto 'https://www.fantasypros.com/nfl/rankings/idp-cheatsheets.php'
    browser.elements(tag_name: 'div', class: 'player-cell').
      wait_until(&:exists?)

    # might be needed to ensure all rows are loaded
    sleep 10
    ranking_table = browser.table(id: "ranking-table")
    player_rows = ranking_table.trs(class: "player-row")
    Player.transaction do
      pool = PlayerPool.create!
      scraped_time = Time.current
      player_rows.each do |row|
        player = Player.new(
          scraped_at: scraped_time, player_pool: pool
        )

        row.each_with_index do |cell, cell_index|
          case cell_index
          when 2
            player.name = cell.a.text
            player.team = cell.
              span(class: "player-cell-team").
              text.gsub(/\W/, '')
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
        player.save!
      end
    end

    browser.close
    File.open(
      "db/seeds/player_pools/football/" \
      "#{Time.current.strftime('%Y%m%d')}-football-idp.json", "w"
    ) do |f|
      f.write(PlayerPool.last.players.to_json)
    end
  end
end
