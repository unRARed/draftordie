class SelectionsController < ApplicationController
  include DraftHelper
  layout "draft"

  before_action :set_selection, except: [:bulk_edit]

  before_action :build_draft_navigation

  def bulk_edit
    @draft = Draft.find_by(slug: params[:draft_slug])
    unless @draft.selections.any?
      skip_authorization
      flash[:alert] = "Draft board must be generated first"
      return redirect_back fallback_location: draft_path(@draft)
    end
    authorize @draft.selections.first
    @rounds = @draft.
      selections_for_display.to_a.group_by(&:round_number)
    @players = {
      remaining: @draft.remaining_players.
        where(is_selected: false).
        map{|p| [p.player_data, p.player_id]},
      selected: @draft.remaining_players.
        where(is_selected: true).
        map{|p| [p.player_data, p.player_id]}
    }
  end

  def edit
    unless @selection.draft.is_started?
      @draft = Draft.preloaded.find(@selection.draft_id)
      flash[:alert] = "Draft has not started yet"
      return render "drafts/show"
    end

    unless @selection.draft.current_selection == @selection
      @draft = Draft.preloaded.find(@selection.draft_id)
      flash[:alert] = "It's not your turn to select"
      return render "drafts/show"
    end
  end

  def update
    unless policy(@selection).bulk_edit?
      return update_for_participant
    end

    # commish actions
    if @selection.update(selection_params)
      flash[:notice] = "Selection updated"
    else
      flash[:alert] = @selection.errors.full_messages.join(", ")
    end
    return redirect_back(
      fallback_location: draft_path(@selection.draft)
    )
  end

private

  def update_for_participant
    @selection.validate
    return render :edit unless @selection.errors.empty?

    begin
      if @selection.update_and_advance(
        { selecting_user: current_user }.merge(selection_params)
      )
        flash[:notice] = "You selected #{selection.name}"
      end
      DraftChannel.broadcast_to(@draft, {
        command: "selection_made", payload: {}
      })
    ensure
      @draft = Draft.preloaded.find(@selection.draft_id)
      return redirect_to draft_path(@selection.draft)
    end
  end

  def selection_params
    params.require(:selection).permit(
      :write_in_name,
      :write_in_team,
      :write_in_position,
      :player_id
    )
  end

  def set_selection
    @selection = Selection.find(params[:id])
    authorize @selection
  rescue Pundit::NotAuthorizedError
    flash[:alert] = "It's not your turn to select"
    redirect_to draft_path(@selection.draft)
  end
end
