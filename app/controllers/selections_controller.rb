class SelectionsController < ApplicationController
  include DraftHelper
  layout "draft"

  before_action :set_selection, except: [:bulk_edit]

  def bulk_edit
    @draft = Draft.find_by(slug: params[:draft_slug])
    unless @draft.selections.any?
      skip_authorization
      flash[:alert] = "Draft board must be generated first"
      return redirect_back fallback_location: draft_path(@draft)
    end
    authorize @draft.selections.first

    build_draft_navigation
    @rounds = @draft.
      selections_for_display.to_a.group_by(&:round_number)
  end

  def edit
    @draft = Draft.preloaded.find(@selection.draft_id)
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

  # For updating a selection a participant
  # has made during the draft
  def update_player_data
    respond_to do |format|
      format.turbo_stream do
        @selection.validate
        return render :edit unless @selection.errors.empty?

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
    if @selection.update_columns(selection_params)
      flash[:notice] = "Selection updated"
    else
      flash[:alert] = @selection.errors.full_messages.join(", ")
    end
    return redirect_back(
      fallback_location: draft_path(@selection.draft)
    )
  end

private

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
    @draft = Draft.preloaded.find(@selection.draft_id)
  rescue Pundit::NotAuthorizedError
    flash[:alert] = "It's not your turn to select"
    redirect_to draft_path(@selection.draft)
  end
end
