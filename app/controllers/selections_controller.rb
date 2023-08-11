class SelectionsController < ApplicationController
  before_action :set_selection

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
    if !@selection.draft.is_running?
      flash[:alert] = "The draft has not started yet"
      return redirect_to draft_path(@selection.draft)
    end
    unless (@selection == @selection.
      draft.progression&.current_selection
    )
      flash[:alert] = "It's not your turn to select"
      return redirect_to draft_path(@selection.draft)
    end

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

private

  def selection_params
    params.require(:selection).permit(
      :write_in_name,
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
