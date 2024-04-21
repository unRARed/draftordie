# The current "progression" of a draft. How we know who
# is currently selecting and who will be selecting when
# this selection is either made or missed.
class Progression
  include ActiveModel::Model

  attr_reader :draft_slug,
    :current_selection_id,
    :next_selection_id,
    :is_selected

  # Wrapper for a given "Draft Board State".
  #
  # @param :state - (ActiveRecord::Relation instance)
  #
  #   Example:
  #     Progression.new(DataStateForDraftBoard.first)
  #
  def initialize(state)
      state.attributes.with_indifferent_access.
      slice(:draft_slug,
        :current_selection_ends_at,
        :current_selection_id,
        :next_selection_id,
        :is_selected
      ).map{|k, v| instance_variable_set("@#{k}", v) }
  end

  def orphaned?
    current_selection_id.nil? && next_selection_id.present?
  end

  def ready_to_advance?
    current_selection_id.present? &&
      Time.current > @current_selection_ends_at
  end

  def ending?
    next_selection_id.nil?
  end
end
