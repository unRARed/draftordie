module ApplicationHelper
  def is_turbo_draft?
    controller.controller_name == "drafts" &&
      ["show", "board"].include?(controller.action_name)
  end
end
