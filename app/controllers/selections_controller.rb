class SelectionsController < ApplicationController
  include DraftHelper
  layout "draft"

  before_action :set_selection

  def edit
    @draft = Draft.preloaded.find(@selection.draft_id)
    return render if policy(@draft).edit?

    unless @selection.draft.is_started?
      flash[:alert] = "Draft has not started yet"
      return render "drafts/show"
    end

    unless @selection.draft.current_selection == @selection
      flash[:alert] = "It's not your turn to select"
      return render "drafts/show"
    end
  end

  def edit_player_data

  end

  def commish_edit
    @draft = Draft.find_by(slug: params[:draft_slug])
    @selection = Selection.find(params[:id])
    authorize @selection
    @selection_for_display = @draft.selections_for_display.
      find_by(selection_id: @selection.id)
  end

  # For updating a selection a participant
  # has made during the draft
  def update_player_data
    respond_to do |format|
      format.turbo_stream do
        @selection.assign_attributes(selection_params)
        @selection.validate
        unless @selection.errors.empty?
          @draft = Draft.preloaded.find(@selection.draft_id)
          flash[:alert] = @selection.errors.
            full_messages.join(", ")
          return redirect_back(fallback_location: draft_path(@draft))
        end

        begin
          if @selection.update_and_advance(
            { selecting_user: current_user }.
              merge(selection_params)
          )
            flash[:notice] = "You selected #{@selection.name}"
            DraftChannel.broadcast_to(@selection.draft, {
              command: "refresh", payload: {}
            })
          end
        end
        head :ok
      end
    end
  end

  def update
    # commish actions - need to go around hooks to
    # avoid setting ended_at - maybe refactor
    @selection.assign_attributes(selection_params)
    if @selection.save
      flash[:notice] =
        "Round #{@selection.round_number} " \
        "Pick #{@selection.pick_number} " \
        "updated to #{@selection.name}"
    else
      flash[:alert] = @selection.errors.full_messages.join("<br>")
    end
    redirect_to board_draft_path(@selection.draft)
  end

private

  def selection_params
    params.require(:selection).permit(
      :is_commish_action,
      :write_in_name,
      :write_in_team,
      :write_in_position,
      :player_id
    )
  end

  def set_selection
    @selection = Selection.find(params[:id])
    authorize @selection
    @draft = Draft.preloaded.find(@selection.draft_id)
  rescue Pundit::NotAuthorizedError
    flash[:alert] = "It's not your turn to select"
    redirect_to draft_path(@selection.draft)
  end
end
