class SelectionsController < ApplicationController
  before_action :set_selection

  def edit
    unless @selection.draft.is_started?
      @draft = Draft.preloaded.find(@selection.draft_id)
      flash[:aler] = "Draft has not started yet"
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

    begin
        next_selection = @selection.
          draft.progression.next_selection
        if @selection.update(
          selection_params.merge(ended_at: Time.current)
        )
          next_selection.update_columns started_at: Time.current

        flash[:notice] = "Selection made"
      end
    rescue
      @draft = Draft.preloaded.find(@selection.draft_id)
      render :edit
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
  end
end
