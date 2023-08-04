module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags "ActionCable",
        "User #{current_user&.id || ''}"
    end

  protected

    def find_verified_user
      if current_user = env['warden'].user
        current_user

      # TODO: we really need 2 different connections, one public
      #       and one private, so we can have a public draft
      #       board that is read-only. anyway, drafts still
      #       require access code, so this may be fine.
      # else
      #   reject_unauthorized_connection
      end
    end
  end
end
